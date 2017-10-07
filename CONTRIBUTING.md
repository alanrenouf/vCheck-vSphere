# Contribute to the vCheck-vSphere repository

Hi! We can't thank you enough for wanting to contribute; the community is what keeps the wheels moving on this awesome project.
All we ask is that you follow some simple guidelines. The roots of these guidelines stem from the developer community and the actual document has been borrowed from [Microsoft's DscResources](https://github.com/PowerShell/DscResources) repository; they did an excellent job putting these guidelines together; why reinvent the wheel?

## Using GitHub, Git, and this repository

We are working on more detailed instructions that outline the basics.

## Contributing to the existing vCheck-vSphere repository

### Forks and Pull Requests

GitHub fosters collaboration through the notion of [pull requests](https://help.github.com/articles/using-pull-requests/).
On GitHub, anyone can [fork](https://help.github.com/articles/fork-a-repo/) an existing repository into their own branch where they can make private changes to the original repository. 
To contribute these changes back into the original repository, a user simply creates a pull request in order to "request" that the changes be taken "upstream". 

#### Lifecycle of a pull reqeust

* **Always create pull requests to the `dev` branch of a repository**. 
For more information, learn about the [branch structure](#branch-structure) that we are using.

![PR-Dev.png](https://github.com/vScripter/vCheck-vSphere/blob/dev/Images/PR-Dev.PNG)

* When you create a pull request, fill out the description with a summary of what's included in your changes. 
If the changes are related to an existing GitHub issue, please reference the issue in your description.
* Once the PR is submitted, we will review your code
* Once the code review is done, and all merge conflicts are resolved, a maintainer will merge your changes.

### Contributing to documentation
One of the easiest ways to contribute to a PowerShell project is by helping to write and edit documentation. 
All of our documentation hosted on GitHub is written using [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) 

*We are at least working on shifting things over to GFM, for 'core' documentation. Some things may still live on the GitHub wiki, but using GFM allows the documentation to exist in the repo, so you always have a local copy to reference ;)*

To [edit an existing file](https://help.github.com/articles/editing-files-in-another-user-s-repository/), simply navigate to it and click the "Edit" button. 
GitHub will automatically create your own fork of our repository where you can make your changes. 
Once you're finished, save your edits and submit a pull request to get your changes merged upstream. 

If you want to contribute new documentation, first check for [issues tagged as "Documentation"](https://github.com/alanrenouf/vCheck-vSphere/labels/documentation) to make sure you're not duplicating efforts.
If no one seems to be working on what you have planned:
* Open a new issue tagged as "Documentation" to tell others what you're working on
* Create a fork of our repository and start adding new Markdown-based documentation to it
* When you're ready to contribute your documentation, submit a pull request to the *dev* branch


#### GitHub Flavored Markdown (GFM)

All of the articles in this repository use [GitHub Flavored Markdown (GFM)](https://help.github.com/articles/github-flavored-markdown/).

If you are looking for a good editor, try [Markdown Pad](http://markdownpad.com/) or 
GitHub also provides a web interface for Markdown editing with syntax highlighting and the ability to preview changes. 

Some of the more basic GFM syntax includes:

* **Line breaks vs. paragraphs:** In Markdown there is no HTML `<br />` or `<p />` element. 
Instead, a new paragraph is designated by an empty line between two blocks of text.
(Note: Please add a single newline after each sentence to simplify the command-line output of diffs and history.)
It will simplify diffs and history.
* **Italics:** The HTML `<em>some text</em>` is written as `*some text*`
* **Bold:** The HTML `<strong>some text</strong>` element is written as `**some text**`
* **Headings:** HTML headings are designated using `#` characters at the start of the line. 
The number of `#` characters corresponds to the hierarchical level of the heading (for example, `#` = `<h1>` and `###` = ```<h3>```).
* **Numbered lists:** To make a numbered (ordered) list start the line with `1. `.  
If you want multiple elements within a single list element, format your list as follows:
```        
1.  For the first element (like this one), insert a tab stop after the 1. 

    To include a second element (like this one), insert a line break after the first and align indentations.
```
to get this output:

1.  For the first element (like this one), insert a tab stop after the 1. 

    To include a second element (like this one), insert a line break after the first and align indentations.

* **Bulleted lists:** Bulleted (unordered) lists are almost identical to ordered lists except that the `1. ` is replaced with either `* `, `- `, or `+ `. 
Multiple element lists work the same way as with ordered lists.
* **Links:** The syntax for a hyperlink is `[visible link text](link url)`.
Links can also have references, which will be discussed in the "Link and Image References" section below.

## Editing an existing plugin

We are in the process of adding/consolidating more detailed documentation around this.

## Creating a new plugin

We are in the process of adding/consolidating more detailed documentation around this. In the meantime, you can review the documentation that we do have inside the [README.md](README.md) file for the repo.

## Internation Language Support

To add support for a specific language to the vCheck, you will have to do the following:

* Create a folder under the Lang folder. The folder shall have the language code of the language for which you are adding support.
* Language strings are loaded from the data files (.psd1). The name of the data file shall correspond with the name of the .ps1 file where the language strings are loaded.
* Language strings are loaded from the main vCheck.ps1 script and from several plugins
* When a data file for a specific plugin is not found, the script logic will revert to en-US
* Use the Use-Culture.ps1 script to test the language you added or updated

The ultimate goal is to remove all language strings from the .ps1 files to data files, or .psd1 files.
The initial examples did this for the main script (vCheck.ps1) and the plugin 79 (79 Find VMs in Uncontrolled Snapshot Mode.ps1).

## Slack

To join in discussions or ask questions, join the #vCheck channel on [VMware Code Slack Team](https://code.vmware.com/slack/).


## Style guidelines

When contributing to this repository, please follow the following guidelines: 

* For all indentation, use 4 spaces instead of tab stops
* Make sure all files are encoding using UTF-8. 
* When writing Markdown, if a paragraph includes more than one sentence, end each sentence with a newline.
GitHub will still render the sentences as a single paragraph, but the readability of `git diff` will be greatly improved. 


## Branch structure

We are using a [git flow](http://nvie.com/posts/a-successful-git-branching-model/) model for development.
We recommend that you create local working branches that target a specific scope of change. 
Each branch should be limited to a single feature/bugfix both to streamline workflows and reduce the possibility of merge conflicts.
![git flow picture](http://nvie.com/img/git-model@2x.png)
