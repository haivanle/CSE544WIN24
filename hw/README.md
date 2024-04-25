
# How to submit homework in this course
<a name="submission"></a>

We will be using `git`, a tool for version control in software engineering, for distributing and submitting homework assignments in this class.
This will allow you to download the code and instructions for the homework 
and also submit the labs in a standardized format.

You will also be able to use `git` to commit your progress on the labs
as you go. This is **important**: Use `git` to back up your work. Back
up regularly by both committing and pushing your code as we describe below.

Course git repositories will be hosted as a repository in [CSE's
gitlab](https://gitlab.cs.washington.edu/) that is visible only to
you and the course staff.


## Note for students with a Windows Operating System

Throughout this course, the instructions for the homework assignments will be given with the assumption that you have access to a bash-style terminal. This used to make working on a Windows laptop a little tricky, but there's a good solution, Windows Subsystem for Linux ([WSL](https://learn.microsoft.com/en-us/windows/wsl/about))! 

This is a function of Windows which allows you to easily run a linux operating sytem within your Windows instance. This is best thought of as a small linux server that also resides on your computer because it has its own distinct file system and everything. We recommend that you do all of the following steps in this document (as well as all of your homework coding) within this system in order to maintain consistency with the provided instructions. 

Starting this system is easy, you just run the following command within Windows PowerShell or Command Prompt to:
```sh
wsl --install
```

After this installation, you should be able to open the linux terminal by simply running `wsl` in PowerShell or Command Prompt. For a more user-friendly interface, we recommend using Visual Studio Code to do you coding. This can be opened by running the following from within your linux terminal,
```sh
code .
```
At this point, you're doing standard linux development but on your Windows computer! 

Note: This is all just a recommendation, and the instructions for the homeworks should be easy to do on Windows without the use of this system, modulo some light translation of the commands. So, feel free to take whatever route you find easiest.


## Getting started with Git

There are numerous guides on using `git` that are available. They range from  fully interactive to just text-based. 
Find one that works and experiment -- making mistakes and fixing them is a great way to learn. 
Here is a [link to resources](https://help.github.com/articles/what-are-other-good-resources-for-learning-git-and-github) 
that GitHub suggests starting with. If you have no experience with `git`, you may find this 
[tutorial helpful](https://try.github.io/levels/1/challenges/1). If you just need a refresher, this [cheat sheet](https://training.github.com/downloads/github-git-cheat-sheet.pdf) might be helpful.

Git may already be installed in your environment; if it's not, you'll need to install it first. 
For `bash`/`Linux` environments, this should be a simple `apt-get` / `yum` / etc. install. 
More detailed instructions may be [found here](http://git-scm.com/book/en/Getting-Started-Installing-Git).

[Recommended] If you're using [Visual Studio Code](https://code.visualstudio.com/Download), git should come pre-installed and most git actions should be able to be handled through the graphical interface. 




## Cloning your repository for homework assignments

We have created a git repository that you will use to commit and submit your the homework assignments. 
This repository is hosted on [CSE's GitLab](https://gitlab.cs.washington.edu) , 
and you can view it by visiting the GitLab website at 
`https://gitlab.cs.washington.edu/cse544-2024wi/cse544-[your CSE or UW username]`. 

 **You'll be using this repository for all of the homework assignments this quarter, so if you don't see this repository or are unable to access it, let us know immediately!**

The first thing you'll need to do is set up an SSH key to allow communication with GitLab:

1.  If you don't already have one, generate a new SSH key. See [these instructions](http://doc.gitlab.com/ce/ssh/README.html) for details on how to do this.
2.  Visit the [GitLab SSH key management page](https://gitlab.cs.washington.edu/profile/keys). You'll need to log in using your CSE account.
3.  Click "Add SSH Key" and paste in your **public** key into the text area.
4. Restart your terminal/open a new one so that the SSH software can "see" the key that you generated

While you're logged into the GitLab website, browse around to see which projects you have access to. You should have access to `cse544-[your CSE or UW username]`. Spend a few minutes getting familiar with the directory layout and file structure. For now, nothing will be there except for the `hw/hw1` directory.

Next, we want to copy the code from the GitLab repository to your local file system so that you can edit it. To do this, you'll need to clone the 544 repository by issuing the following commands on the command line:

```sh
$ cd [directory that you want to put your 544 assignments]
$ git clone git@gitlab.cs.washington.edu:cse544-2024wi/cse544-[your CSE or UW username].git
$ cd cse544-[your CSE or UW username]
```

This will make a complete replica of the repository locally. If you get an error that looks like:

```sh
Cloning into 'cse544-[your CSE or UW username]'...
Permission denied (publickey).
fatal: Could not read from remote repository.
```

... then there is a problem with your GitLab configuration. Check to make sure that your GitLab username matches the repository suffix, that your private key is in your SSH directory (`~/.ssh`) and has the correct permissions, and that you can view the repository through the website. 

Cloning will make a complete replica of the homework repository locally. **When you make changes to this local folder, they will not automatically be sent to the course server!** To allow the course staff to see these changes, you will nee to make sure that you `git commit` and `git push` your local changes. Since we'll be grading the copy in the GitLab repository, it's important that you remember to push all of your changes!

## Adding an upstream remote to get homework updates

The repository you just cloned is a replica of your own private repository on GitLab. The copy on your file system is a local copy, and the copy on GitLab is referred to as the `origin` remote copy.  You can view a list of these remote links as follows:

```sh
$ git remote -v
```

There is one more level of indirection to consider. When we created your `cse544-[your CSE or UW username]` repository, we forked a copy of it from another repository `cse544-2024wi`.  In `git` parlance, this "original repository" is referred to as an `upstream` repository. When we release bug fixes and subsequent homeworks, we will put our changes into the upstream repository, and you will need to be able to pull those changes into your own personal repository.  See [the documentation](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes) for more details on working with remotes -- they can be confusing!

In order to pull the changes from the upstream repository, we'll need to record a link to the `upstream` remote in your own local repository:

```sh
$ # Note that this repository does not have your username as a suffix!
$ git remote add upstream git@gitlab.cs.washington.edu:cse544-2024wi/cse544-2024wi.git
```

For reference, your final remote configuration should read like the following when it's setup correctly:

```sh
$ git remote -v
  origin  git@gitlab.cs.washington.edu:cse544-2024wi/cse544-[your CSE username].git (fetch)
  origin  git@gitlab.cs.washington.edu:cse544-2024wi/cse544-[your CSE username].git (push)
  upstream    git@gitlab.cs.washington.edu:cse544-2024wi/cse544-2024wi.git (fetch)
  upstream    git@gitlab.cs.washington.edu:cse544-2024wi/cse544-2024wi.git (push)
```

In this configuration, the `origin` (default) remote links to **your** repository 
where you'll be pushing your individual submission. The `upstream` remote points to **our** 
repository where you'll be pulling subsequent homework and bug fixes (more on this below).

## Pushing to your repository
Let's test out the origin remote by doing a push of your master branch to GitLab. Do this by issuing the following commands:

```sh
$ # Make a file without any contents
$ touch empty_file
$ # Tell git that you want it to track that file as part of the repository
$ git add empty_file
$ # Commit your progress locally (like a checkpoint)
$ git commit -a -m 'Testing git'
$ # Tell git to update the remote repository to match your local commits
$ git push # ... to origin by default
```

The `git push` tells git to push all of your **committed** changes to a remote.  If none is specified, `origin` is assumed by default (you can be explicit about this by executing `git push origin`).  Since the `upstream` remote is read-only, you'll only be able to `pull` from it -- `git push upstream` will fail with a permission error.

After executing these commands, you should see something like the following:

```sh
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 286 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
To git@gitlab.cs.washington.edu:cse544-2024wi/cse544-[your CSE or UW username].git
   cb5be61..9bbce8d  master -> master
```

We pushed a blank file to our origin remote, which isn't very interesting. Let's clean up after ourselves:

```sh
$ # Tell git we want to remove this file from our repository
$ git rm empty_file
$ # Now commit all pending changes (-a) with the specified message (-m)
$ git commit -a -m 'Removed test file'
$ # Now, push this change to GitLab
$ git push
```

If you don't know Git that well, this probably seemed very arcane. Just keep using Git and you'll understand more and more. We'll provide explicit instructions below on how to use these commands to actually indicate your final lab solution.

VSCode: If you're using Visual Studio Code, then each step of this process can be handled through the "source control" panel on the left of the window.

## Pulling from the upstream remote

If we release additional details or bug fixes for this homework, 
we'll push them to the repository that you just added as an `upstream` remote. You'll need to `pull` and `merge` them into your own repository. (You'll also do this for subsequent homeworks!) You can do both of these things with the following command:

```sh
$ git pull upstream main
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
From gitlab.cs.washington.edu:cse544-2024wi/cse544-2024wi
 * branch            main     -> FETCH_HEAD
   7f81148..b0c4a3e  main     -> upstream/main
Merge made by the 'recursive' strategy.
 README.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Here we pulled and merged changes to the `README.md` file. Git may open a text editor to allow you to specify a merge commit message; you may leave this as the default. Note that these changes are merged locally, but we will eventually want to push them to the GitLab repository (`git push`).

Note that it's possible that there aren't any pending changes in the upstream repository for you to pull.  If so, `git` will tell you that everything is up to date.

## Submitting your assignment

Now that you have your repository set up properly, submitting your assignments should be easy! For each assignment, you will need to do the following steps:
1. Place the requested submission files in the folder labeled `hw/hw[X]/submission`.
2. Run `git add hw/hw[X]/submission` to add the files to your local git repository
3. Run `git commit -a -m "[Some Commit Message]"` to commit your progress
4. Run `git push` to upload your commit to GitLab

If you submit unfinished code or want to change your submission prior to the deadline, don't worry! You can always run steps 2-4 again to update your submission; we will use the latest version that arrives before the deadline. 

The criteria for your homework being submitted on time is that your code must
pushed by the due date and time. This means that if one of the TAs or the instructor were to open up GitLab, they would be able to see your solutions on the GitLab web page.


The criteria for your homework being submitted on time is that your code must
pushed by the due date and time. This means that if one of the TAs or the instructor were to open up GitLab, they would be able to see your solutions on the GitLab web page.

**Just because your code has been committed on your local machine does not mean that it has been submitted -- it needs to be on GitLab!**

## Final Word of Caution!

Git is a distributed version control system. This means everything operates offline until you run `git pull` or `git push`. This is a great feature.

The bad thing is that you may **forget to `git push` your changes**. This is why we strongly, strongly suggest that you **check GitLab to be sure that what you want us to see matches up with what you expect**.  As a second sanity check, you can re-clone your repository in a different directory to confirm the changes:

```sh
$ git clone git@gitlab.cs.washington.edu:cse544-2024wi/cse544-[your CSE or UW username].git confirmation_directory
$ cd confirmation_directory
$ # ... make sure everything is as you expect ...
```

**ALSO IMPORTANT**: In order for your write-up to be added to the git repo, you need to explicitly add it:

```sh
$ git add hw/hw[X]/submission
```

## Collaboration

All CSE 544 assignments are to be completed **individually**! However, you may discuss your high-level approach to solving each lab with other students in the class.
