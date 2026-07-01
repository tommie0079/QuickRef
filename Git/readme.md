# Git Quick Reference

## Install Git

### Windows
```powershell
winget install --id Git.Git -e --source winget
```

### Verify
```bash
git --version
```

## Clone (Download) a Repository

```bash
git clone https://github.com/user/repository.git
cd repository
```

## Check Status

```bash
git status
```

## Add Files

Add all changed files:
```bash
git add .
```

Add a specific file:
```bash
git add filename.txt
```

## Commit Changes

```bash
git commit -m "Describe your changes"
```

## Push to GitHub

```bash
git push
```

## Pull Latest Changes

```bash
git pull
```

## First-Time Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```


Most common workflow:

git clone <repo-url>
cd <repo>

# Make changes

git add .
git commit -m "Updated files"
git push
