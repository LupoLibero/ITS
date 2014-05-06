format = require('util').format
exec = require('child_process').exec
spawn = require('child_process').spawn
Q = require('q')
fs = require('fs')

PROD_DB_URL = "http://db.lupolibero.org/lupolibero"
VAGRANT_INVENTORY = '.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory'
VAGRANT_SSH_KEY = '~/.vagrant.d/insecure_private_key'
VAGRANT_SSH_USER = 'vagrant'

usage = ->
  console.log """Usage:
  help                           display this message
  [prod] bots push [inventory]   push the bots (and proxy) to env (or default)
  [prod] app push [env|url]      push the app to url or the URL associated to env
                                 (or default)
  [prod] app init [env|url]      replicate the production db to url and then push
                                 the app
  [prod] push [env|url]          bots push + app push
  [prod] init [env]              bots push + app init

  To deploy to production, prod argument must be present
  """

production = false
plusOneIfProd = (nb) ->
  return nb + (if production then 1 else 0)

lastArgOrDefault = (argNum) ->
  console.log argNum
  if process.argv.length > argNum
    return process.argv[argNum]
  else
    return "default"

urlWithoutCredentials = (url) ->
  return url.replace(/\/\/.*@/, '\/\/')

getUrlFromEnv = (envOrUrl) ->
  console.log "get url from", envOrUrl
  if (envOrUrl[0..6] == 'http://' or
      envOrUrl[0..7] == 'https://')
    return envOrUrl
  envs = require('./.kansorc').env
  console.log
  if envs and envOrUrl of envs
    return envs[envOrUrl].db
  throw format("invalid environment: %s", urlWithoutCredentials(envOrUrl))

copyFileSync = (srcFile, destFile) ->
  BUF_LENGTH = 64*1024
  buff = new Buffer(BUF_LENGTH)
  fdr = fs.openSync(srcFile, 'r')
  fdw = fs.openSync(destFile, 'w')
  bytesRead = 1
  pos = 0
  while bytesRead > 0
    bytesRead = fs.readSync(fdr, buff, 0, BUF_LENGTH, pos)
    fs.writeSync(fdw,buff,0,bytesRead)
    pos += bytesRead
  fs.closeSync(fdr)
  fs.closeSync(fdw)

callCommand = (cmd) ->
  deferred = Q.defer()
  console.log cmd
  args = cmd.split(" ")
  console.log args
  p = spawn(args[0], args[1..])

  #p.stdout.on('data', (data) ->
  #  console.log(data.toString())
  #)
  p.stdout.pipe(process.stdout)
  p.stderr.pipe(process.stderr)
  p.on('close', (code)  ->
    if code > 0
      deferred.reject()
    else
      deferred.resolve()
  )
  return deferred.promise


# Install bots files on the server fs
# and reload them
botsPush = (env) ->
  deferred = Q.defer()
  console.log "node manager.js bots push", env
  if production
    if fs.existsSync("ansible/production")
      inventory = "ansible/production"
  else if fs.existsSync("ansible/hosts")
    inventory = "ansible/hosts"
  else
    inventory = VAGRANT_INVENTORY
    ssh_key = VAGRANT_SSH_KEY
    user = VAGRANT_SSH_USER
  callCommand(
    "ansible-playbook ansible/site.yml -i " +
    inventory + " " +
    (if ssh_key then "--private-key=" + ssh_key + " " else '') +
    (if user then "-u " + user + " " else '') +
    "--limit " + env + " --tags deploy -K"
  ).then(->
    url = getUrlFromEnv(env)
    callCommand(format("coffee bots/external_tools %s", url))
  )

# Reload the application in the db
appPush = (envOrUrl) ->
  deferred = Q.defer()
  url = getUrlFromEnv(envOrUrl)
  console.log "node manager.js app push", urlWithoutCredentials(url)
  callCommand(format("kanso push %s", url))

# Clone the production db
appInit = (envOrUrl) ->
  deferred = Q.defer()
  url = getUrlFromEnv(envOrUrl)
  console.log "node manager.js app init", urlWithoutCredentials(url)
  callCommand(format("kanso replicate %s %s", PROD_DB_URL, url))



if process.argv[2] == "prod"
  production = true

# node manager.js [help]
if (process.argv.length == 2 or process.argv.length == 3 and
  process.argv[2] == "help")
    usage()

# node manager.js bots push [env]
 # cp files to ansible/role/...
 # ansible inventory
else if process.argv[plusOneIfProd(2)] == "bots"
  if process.argv.length == plusOneIfProd(3)
    usage()
  if process.argv[plusOneIfProd(3)] == "push"
    env = lastArgOrDefault(plusOneIfProd(4))
    botsPush(env)

# node manager.js app push [env|url]
 # kanso push url
else if process.argv[plusOneIfProd(2)] == "app"
  if process.argv.length == plusOneIfProd(3)
    usage()
  envOrUrl = lastArgOrDefault(plusOneIfProd(4))
  if process.argv[plusOneIfProd(3)] == "push"
    appPush(envOrUrl)

# node manager.js app init [env|url]
 # kanso replicate prod url
 # node manager.js app push url
  else if process.argv[plusOneIfProd(3)] == "init"
    appInit(envOrUrl).then(-> appPush(envOrUrl))

# node manager.js push [env]
 # node manager.js bots push env
 # node manager.js app push url
else if process.argv[plusOneIfProd(2)] == "push"
  env = lastArgOrDefault(plusOneIfProd(3))
  botsPush(env).then(-> appPush(env))

# node manager.js init [env]
 # node manager.js bots push env
 # node manager.js app init env
else if process.argv[plusOneIfProd(2)] == "init"
  env = lastArgOrDefault(plusOneIfProd(3))
  botsPush(env).then(-> appPush(env))


process.on 'uncaughtException', (err) ->
  console.error('An uncaughtException was found, the program will end.')
  console.error(err)
  process.exit(1)
