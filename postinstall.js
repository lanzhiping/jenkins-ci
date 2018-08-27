const fs = require('fs')

function setupGitHookFile(hookName) {
  fs.copyFile(`scripts/${hookName}`, `.git/hooks/${hookName}`, (err) => {
    if (err) {
      console.log('has error setting up hook for ' + hookName)
      throw err
    }
    fs.chmodSync(`.git/hooks/${hookName}`, '755')
    console.log(`setup ${hookName} done.`)
  })
}

setupGitHookFile('pre-commit')
