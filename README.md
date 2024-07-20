# GitBar
GitBar is an [xbar plugin](https://github.com/matryer/xbar-plugins) that will keep you updated on the branches and open pull requests on one or many repository. It refreshes every 1 minute.


![image](https://github.com/user-attachments/assets/ab99b921-86ce-4642-bead-24a55be659f2)

# Installation
Git Clone this repo, cd in the folder and run the following commands to install the plugin:

As said above, it is an xbar plugin, so you'll need it installed to use GitBar :
```
brew install --cask xbar
```

GitBar uses `gh` to fetch the latest release of the repo. You will need to install [GitHub CLI](https://github.com/cli/cli) to use this plugin and also login to your github account.
```
brew install gh
gh auth login
```

Inside gitbar_app/config, you'll find a `settings.json.example`, update the username and repositories list before next step and rename it to `settings.json`.

Finally, there is [a script](https://github.com/paultursuru/gitbar/blob/9b854c7ae43783a9a45ce98a7e5e0b8c81c16d08/copy_to_plugins.sh) to install the app in xbar plugins. Make this script executable and run it to copy the GitBar plugin inside the xbar plugins folder.
```
chmod +x copy_to_plugins.sh
./copy_to_plugins.sh
```

Whenever you need to add or remove repositories to track, update the json file and re-run `./copy_to_plugins.sh`
