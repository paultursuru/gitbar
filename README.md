# GitBar
GitBar is an [xbar plugin](https://github.com/matryer/xbar-plugins) that will keep you updated on the branches and open pull requests on one or many repository. It refreshes every 1 minute.

<img width="879" alt="image" src="https://github.com/user-attachments/assets/5e54abc0-25e2-478c-89a0-103104ae512a">

## Information displayed
### Header
- Name and status icon for the first repo of the list with :
  - PR ready to merge counter (✅)
  - PR with changes requested counter (❌)
  - PR with review requested counter (👀)

### Per-repository display
- Repository name (link with a status icon for the default branch)
- Status checks (each check’s description, direct link, and relative time)
  - On my setup, I get the CI and Deployment status checks (TODO : Should become configurable)
- Pull requests grouped:
  - Review requested (👀)
  - Already reviewed (👍) (or no reviews needed)
  - Your open PRs (🤓)
- Branches without an open PR (link to "compare and open PR" page)
- For each PR:
  - Title (link)
  - Branch name (link)
  - Latest review state per reviewer
  - Combined status check state (CI status, Deployment status if any)
  - Mergeability (No conflict, Conflicts, etc)
  - Time since last update (for items awaiting your review)
- Footer: 
  - “Last updated” timestamp
  - “Offline mode” message if connection is lost


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
This file here : 
<img width="695" alt="image" src="https://github.com/user-attachments/assets/e0f6b640-0be0-4838-a110-3988074e63f0">


Finally, there is [a script](https://github.com/paultursuru/gitbar/blob/9b854c7ae43783a9a45ce98a7e5e0b8c81c16d08/copy_to_plugins.sh) to install the app in xbar plugins. Make this script executable and run it to copy the GitBar plugin inside the xbar plugins folder.
```
chmod +x copy_to_plugins.sh
./copy_to_plugins.sh
```

You can change the refresh rate by changing the "1m" in the name of this file to any other time value 10s, 2h, etc
```
gitbar.10s.rb
gitbar.2h.rb
```

Whenever you need to add or remove repositories to track, update the json file and re-run `./copy_to_plugins.sh`

