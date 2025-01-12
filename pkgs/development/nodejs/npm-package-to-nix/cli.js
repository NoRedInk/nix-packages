#!/usr/bin/env node

var yargs = require('yargs')
var fs = require('fs')
var asyncNpmPackageToNix = require('./lib/asyncNpmPackageToNix')

var argv = yargs
  .usage('Generate Nix expressions from package.json and package-lock.json\n\nUsage: $0 [options]')
  .alias('version', 'v')
  .help('help').alias('help', 'h')
  .option('p', {
    alias: 'package',
    default: './package.json',
    describe: 'Path to the package.json file',
    type: 'string',
  })
  .option('l', {
    alias: 'package-lock',
    default: './package-lock.json',
    describe: 'Path to the package-lock.json file',
    type: 'string',
  })
  .option('o', {
    alias: 'output',
    default: './npm-package.nix',
    describe: 'Output .nix file',
    type: 'string',
  })
  .strict()
  .argv

try {
  var pkgJsonContent = fs.readFileSync(argv.p, 'utf8')
  var pkgLockJsonContent = fs.readFileSync(argv.l, 'utf8')
  var pkg = JSON.parse(pkgJsonContent)
  var pkgLock = JSON.parse(pkgLockJsonContent)
  asyncNpmPackageToNix(pkg, pkgLock).then(function (nixstr) {
    nixstr = '# This file is generated by npm-package-to-nix. Do not edit.\n\n' + nixstr
    fs.writeFileSync(argv.o, nixstr)
    console.error('Nix expression saved to ' + argv.o)
  }).catch(function (e) {
    yargs.showHelp('error')
    console.error('\n', e)
    process.exit(-1)
  })
} catch (e) {
  yargs.showHelp('error')
  console.error('\n', e)
  process.exit(-1)
}
