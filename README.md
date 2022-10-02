# Using OrgFlow in GitHub Actions

OrgFlow is true Git-based DevOps for Salesforce - which works great in GitHub! :octocat: ♥️ ☁️

This repository can be used in two ways:

- As a set of basic sample workflows that show how to use OrgFlow in GitHub Actions
- As a template repository that you can use as a starting point

In this repository you'll find a few sample workflows to quickly get you up and running with OrgFlow in GitHub Actions, but they are only a starting point. You will likely want to change things to suit your specific needs once you've got the hang of it. With some creativity, you will be able to use OrgFlow to build your own Salesforce DevOps pipeline and manage your Salesforce deployments from GitHub.

Below is a guided tutorial on how you can quickly get up and running with your own repository, using this one as a template.

## Preparations

### 1. Create some sandboxes

We'll need a couple of sandboxes to make full use of this guide. OrgFlow can create them for you, but for now, let's have you create them manually to save on build minutes. Log into your production Salesforce org, and create two sandboxes, let's name them `OFQA` and `OFUAT`. You don't need to wait for them to be created and activated - continue with this guide until we need them further down.

### 2. Create a repository

This is a template repository, and you'll need to create a new repository (using this repository as a template) to be able to follow this guide. Click the green "use this template" button near the top of the page, and follow the instructions. **Make sure that you create a private repository** because we'll be committing your Salesforce metadata to it.

## Getting started

### 1. Set the required secrets

You'll need to set some values before you can run the workflows in this repository.

Go to **Settings > Secrets** and add the following secrets:

| Name                  | Value                                                                                                                                                                                                              |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ORGFLOW_LICENSEKEY`  | Your OrgFlow license key (you can get one at https://www.orgflow.io/trial if you do not already have one)                                                                                                          |
| `ORGFLOW_STACKNAME`   | The name of the stack that you'd like to create (e.g. `MyStack`)                                                                                                                                                   |
| `SALESFORCE_USERNAME` | Your Salesforce production username                                                                                                                                                                                |
| `SALESFORCE_PASSWORD` | Your Salesforce production password (remember to [add your security token to the end of your password](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_concepts_security.htm) if needed) |

#### 1b. (Optional) Choose what to include

You probably don't want to keep _all_ of your Salesforce metadata in sync across your environments. OrgFlow has a powerful metadata filtering syntax that allows you to pick and choose the metadata types and components that do and don't get included.

We've included a basic [.orgflowinclude](.orgflowinclude) file for you to get started with; feel free to make changes (or not). We also have [some docs](https://docs.orgflow.io/reference/glossary/orgflow-include-file.html) describing how this file works.

### 2. Create your stack

A _stack_ is a link between Salesforce and a Git repository, and also a collection of _environments_.

Go to the **Actions** tab in this repo, and run the workflow called **Create the stack**.

When OrgFlow creates your stack, it will also create your first environment (named `Production`). This environment is connected to the production Salesforce org that you provided the username and password for. You will see that a Git branch called `production` has been created too, and that the metadata from your Salesforce org has been committed to this branch.

### 3. Add another environment

An _environment_ is a link between a specific Salesforce org (production or sandbox) and a branch in your Git repository. You already created an environment for your production org when you created the stack, but now we are going to create an environment for a sandbox org.

> NOTE: At this point, make sure that the `OFQA` and `OFUAT` sandboxes that you created in the "First things first" section have been created and activated before continuing.

Go to the **Actions** tab in this repo, and run the workflow called **Create an environment**.

Let's use the name `QA` for the new environment. Provide the name of your existing `OFQA` sandbox, and enter the branch name `sandbox/qa`. The branch will be created for you.

#### 3b. Add another environment (again)

You'll want two sandbox environments on your stack (so that you don't need to make any changes to production), so repeat the step from above. This time, let's name the second environment `UAT`. Provide the name of your existing `OFUAT` sandbox, and `sandbox/uat` for the branch name. The branch will be created for you.

### 4. Change some metadata in Salesforce

By now, you should have the metadata from your two sandboxes and your production Salesforce org committed to this repository. OrgFlow has committed the metadata for each org to its backing Git branch. This allows you to compare (diff) and merge the branches as you require.

Right now, the whole stack is in a state of _complete consistency_. This means that all three environments, their Git branches and Salesforce orgs, are identical when it comes to the subset of metadata you chose to include in your stack. There are no metadata changes yet to flow from one environment to another. Let's change some metadata in one of the sandboxes that you created in the previous step, and commit that change.

We'll keep things simple and start with custom objects (if you have changed the `.orgflowinclude` file to not include custom objects, then you may need to pick another metadata type to make some changes to). Log into the `OFQA` sandbox, and add a custom object named `Car` (you can configure it however you please).

### 5. Flow your change to another Salesforce org

We've added our `Car` object to the `OFQA` sandbox, now let's flow it (merge and deploy it) to the `OFUAT` sandbox.

Go to the **Actions** tab in this repo, and run the workflow called **Commit Salesforce metadata changes**. Enter the environment name `QA` (because this is the environment name that we chose when adding the `OFQA` sandbox as an environment), and optionally add a commit message (maybe "Adds Car object"). Run the workflow and wait for it to complete.

You'll notice that the `Car` object is now in your repo (in the `sandbox/qa` branch).

Create a pull request to merge the changes from the branch `sandbox/qa` into `sandbox/uat`. This is a good opportunity to see and review the changes being made - you'll see the diff between the two branches, and you can also leave comments or a review if you like.

You'll also notice that GitHub initiates a check called **Validate PR** on this pull request. This check consists of a workflow that takes advantage of GitHub's `pull_request` trigger to run an OrgFlow command that performs a check-only deployment of the merge result. The results are then added to the pull request as a comment, allowing you to check whether all the components that have been changed are deployable.

Once you're happy with the change, merge the pull request. **Do not squash or rebase - OrgFlow needs the entire commit history in order to facilitate some of its more advanced features** (see step 6).

Go to the **Actions** tab again, and run the workflow named **Deploy metadata**. Enter the environment name `UAT` (because this is the environment name that we chose when adding the `OFUAT` sandbox as an environment). This workflow will comapre the metadata in the `sandbox/uat` branch to the metadata in the `OFUAT` sandbox and deploy any differences into the sandbox.

Note that although we manually triggered this workflow, it would also be possible to use the standard `push` GitHub Action trigger to watch for changes to the branch and run this workflow whenever changes are pushed to the branch.

Wait for that workflow to complete, and then log into the `OFUAT` sandbox - you'll see that the `Car` object is now in this sandbox too.

### 6. Advanced merging

Finally, let's make two changes to the same component from different sandboxes. With many other Salesforce deployment tools, deploying two changes to the same metadata component is likely to end up overwriting the changes from one org, with the changes from the other.

OrgFlow, on the other hand, is smart enough to merge these changes. Let's try it out!

Log into your `OFQA` sandbox and edit the label of the `Car` object. Change it to `Vehicle` (leave the API name as it is). Next, log into your `OFUAT` sandbox and make a change to the description of the `Car` object.

> TIP: If you're feeling adventurous, you can edit the label in **both** sandboxes - you'll end up with a _merge conflict_. OrgFlow fully embraces the occurrence of merge conflicts, and you can simply use standard Git conflict resolution techniques to resolve them, but that's beyond the scope of this basic guide.

Now that we've made your changes, we need to get them into Git. Go to the **Actions** tab, and there's a workflow named **Commit Salesforce metadata changes for all environments**. This workflow has been set up to run on a schedule every night at 1 am, but why wait until then? Click the **Run workflow** drop-down, then click the green **Run workflow** button to manually trigger this workflow.

In a previous step, we used a similar (but different) workflow to flow in the changes from a **single** environment. This workflow queries OrgFlow for a list of all environments, and then will flow each one in. If you've been following this guide, then that's three environments in total (`Production`, `QA`, and `UAT`).

Once that workflow has completed, create another pull request to merge the changes from the branch `sandbox/qa` into `sandbox/uat`. You'll notice that the changes can be merged, so press the **Merge** button, and wait for the automatic deployment workflow to trigger again. Once that workflow run is complete, you'll notice that the `Car` object in the sandbox `OFUAT` has been updated with the changes from the other sandbox, and that the changes already in `OFUAT` were retained too.

If you'd like to merge the changes back into the `OFQA` sandbox, then you simply need to create and merge another pull request (this time from the branch `sandbox/uat` into `sandbox/qa`), and then run the **Deploy metadata** workflow.

## Enumerating environments

The **Commit Salesforce metadata changes for all environments** workflow shows an example of enumerating environments in your stack and performing some work (in this case an inbound flow) for a subset of them in parallel using a GitHub Actions matrix job in your workflow.

You may have other jobs that you want to run against multiple environments only known at runtime. You can take advantage of the `env:list --output=json` command to retrieve all of the environment names in a stack and use a matrix strategy to run a job once for each environment. 

The trick here is to use the `--nameOnly` switch and a tool called [jq](https://stedolan.github.io/jq/) to transform the output from `env:list --nameOnly --output=json` into the format that GitHub Actions expects for a matrix definition. The correct jq syntax for this is `env:list --nameOnly --output=json | jq '.' -c`. On top of this, `jq` offers a robust filtering syntax, for example if you only want to run your job on environments matching certain criteria.

`jq` is pre-installed on GitHub-hosted runners, and it is also pre-installed in the official OrgFlow CLI Docker image.

Here are some examples of useful `jq` commands you can apply to the output of `env:list`:

- Get an environment by name: `env:list --output=json | jq '[.[] | select(.name == "myEnvironmentName")] | select(. | length > 0)[0]' -c`
- Get an environment by Git branch: `env:list --output=json | jq '[.[] | select(.git.branch == "myGitBranch")] | select(. | length > 0)[0]' -c`
- Get the name of the production environment: `env:list --output=json | jq '[.[] | select(.org.production == true) | .name] | select(. | length > 0)[0]' -c`
- Get the names of all the environments and transform them into a format that GitHub Actions will accept as a matrix: `env:list --nameOnly --output=json | jq '.' -c`

> TIP: You can use the [`env:tags:set`](https://docs.orgflow.io/reference/commands/env-tags-set.html) command to tag environments, and then use those tags to filter the environments returned by `env:list`. For example, to list only the environments tagged with `runNightlyApexTests`, you could do `env:list --withTags=runNightlyApexTests --output=json`.

## Next steps

This guide was simply an introduction to how some of the most fundamental operations of OrgFlow can be integrated into GitHub Actions.

The real power lies in the infinite possibilities and flexibility this integration provides. You have at your disposal the full power of GitHub Actions, the rich ecosystem of third-party actions, and a universe of scriptable CLI tools. Your creativity and engineering cleverness are the only limits to the kinds of Salesforce DevOps pipelines you can create, and the extent to which you can automate them.

Take a look at the [workflow YAML files](.github/workflows) in this repository to learn how we did what we just did. There are a few more examples in there too, that we didn't cover in this guide.
