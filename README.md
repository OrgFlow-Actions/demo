# Welcome to OrgFlow

OrgFlow is a true CI & CD tool for Salesforce. :octocat: ♥️ ☁️

This repository contains a few sample workflows to quickly get you up and running, but feel free to change things around a bit to suit your needs once you have got the hang of it.

## First things first
This is a template repository, and you'll need to create a new repository (using this repository as a template) to be able to follow this guide.

![image](https://user-images.githubusercontent.com/2872984/133998220-1a4e6ec7-2400-43f1-9acd-4782a5ee219a.png)

Click the big, green, `Use this template` button near the top of this page, and follow the instructions. **Make sure that you create a private repository** because we'll be committing your Salesforce metadata to it.

## Getting started

### 1. Set the required secrets
You'll need to set some values before you can run the actions in this repository. 

Go to `Settings` > `Secrets` and add the following records:

| Name | Value |
| --- | --- |
| `ORGFLOW_LICENSEKEY` | \<Your OrgFlow license key\> |
| `ORGFLOW_STACKNAME` | \<The name of the stack that you'd like to create (e.g. `MyStack`)\> |
| `SALESFORCE_USERNAME` | \<Your Salesforce username\> |
| `SALESFORCE_PASSWORD` | \<Your Salesforce password (remember to [add your security token to the end of your password](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_concepts_security.htm) if you need to)\> |


#### 1b. (Optional) Choose what to include
You probably don't want to keep *all* of your Salesforce metadata in sync. OrgFlow has a powerful metadata filtering syntax that allows you to pick and choose the types and objects that do and don't get included.

We've included a basic [.orgflowinclude](.orgflowinclude) file for you to get started with; feel free to make changes (or not). We've also got [some docs on this topic](https://docs.orgflow.io/reference/glossary/orgflow-include-file.html).

### 2. Create your stack
A stack is a link between Salesforce and a Git repository.

Go to the `Actions` tab in this repo, and run the workflow called `Create the stack`.

### 3. Add another environment
Environments are a link between a specific Salesforce org and a branch within the Git repository. You already created an environment for your production org when you created the stack, but now we are going to create an environment for a sandbox org.

Go to the `Actions` tab in this repo, and run the workflow called `Create an environment`.

Pick a unique name for this environment (your stack only contains a single environment at the moment, and it is called `Production`, so just pick anything other than `Production`). We recommend simply `A`.

Provide sandbox and Git branch names (we recommend `OrgFlowA` and `sb/orgflowa` respectively).

> TIP- create the sandbox manually in Salesforce before you run this workflow. It'll save on build minutes, and it also helps work around a known issue in Salesforce where credentials for new sandboxes can take a while to propagate.

#### 3b. Add another environment
You'll want two sandbox environments on your stack (so that you don't need to make any changes to production), so repeat the step from above. We recommend `B`, `OrgFlowB`, and `sb/orgflowb` for environment name, sandbox name, and Git branch name respectively.

### 4. Change some metadata
By now, you should have the metadata from your two sandboxes and your production Salesforce org committed to this repository. OrgFlow has committed the metadata to each branch that is backing the org (as you specified in the previous steps). This allows you to compare (diff) and merge the branches as you require.

But first- let's change some metadata in one of the sandboxes that you created in the previous step, and commit that change:

We'll keep things simple and start with Custom Objects (if you changed the `.orgflowinclude` file (see step 1b), then you may need to pick another metadata type). Log into the `OrgFlowA` sandbox, and add an object called `Car` (you can configure it how you please).

Next, got to the `Actions` tab in this repo, and run the workflow called `Flow in an environment`. Enter the environment name `A` (because this is the environment name that we chose when adding the `OrgFlowA` sandbox as an environment), and optionally add a commit message (maybe `Adds Car object`). Run the workflow and wait for it to complete.

You'll notice that the car object is now in your repo.

### 5. Move your change to another Salesforce org
We've added our `Car` object to the `OrgFlowA` sandbox, now let's deploy it to the `OrgFlowB` sandbox.

Create a pull request to merge the changes from the branch `sb/orgflowa` into `sb/orgflowb`. This is a good chance to see and review the changes being made- you'll see the diff between the two branches, and you can also leave comments or a review if you'd like to.

Once you're happy with the change, merge the pull request. **Do not squash and merge or rebase and merge- OrgFlow needs the entire commit history in order to facilitate some of its more advanced features** (see step 6).

Go to the `Actions` tab again, and you'll notice that an action has automatically been triggered to deploy this change. We've just used a standard GitHub Action trigger to watch for changes to the branch, and then the workflow simply uses OrgFlow to deploy the change to the correct sandbox.

Wait for that action to complete, and then log into the `OrgFlowB` sandbox- you'll see that the car object is now in this sandbox too.

### 6. Advanced merging
Finally, let's make two changes to the same object from different sandboxes. If you used other deployment tools to try and deploy these changes, you'd end up overwriting the changes from one org with the changes from the other.

OrgFlow, on the other hand, is smart enough to merge these changes. Let's try it out:

Log into your `OrgFlowA` sandbox and edit the label of the `Car` object- change it to `Vehicle` (leave the API name as it is).

Next, log into your `OrgFlowB` sandbox and edit the description of the `Car` object.

> TIP- if you edit the same field in both sandboxes, you'll end up with a merge conflict. You could simply use standard Git conflict resolution techniques to resolve this, but it's out of the scope of this guide.

Now that we've made your changes, we need to get them into Git. Go to the `Actions` tab, and there's an action called `Flow in all environments`. This action has been set up to run on a schedule every night at 1 am, but why wait till then? Click the `Run workflow` drop-down, then click the green `Run workflow` button to manually trigger this workflow.

In a previous step, we used a similar (but different) action to flow in the changes from a single environment. This action queries OrgFlow for a list of all environments, and then will flow each one in. If you've been following this guide, then that's three environments in total (`Production`, `A`, and `B`).

Once that action has been completed, create another pull request to merge the changes from the branch `sb/orgflowa` into `sb/orgflowb`. You'll notice that the changes can be merged, so press the `Merge` button, and wait for the automatic deployment action to trigger again. Once that action is complete, you'll notice that the car object in the sandbox `OrgFlowB` has been updated with the changes from the other sandbox, and that the changes already in `OrgFlowB` were retained too.

If you'd like to merge the changes back into the `OrgFlowA` sandbox, then you simply need to create and merge another pull request (this time from the branch `sb/orgflowb` into `sb/orgflowa`).

## Next steps
This guide was simply an introduction to what OrgFlow can do, and how you can integrate it into CI & CD tools.

Take a look at the [workflow files](.github/workflows) to learn how we did what we just did. There are a few examples in there that we didn't cover in this guide, too.
