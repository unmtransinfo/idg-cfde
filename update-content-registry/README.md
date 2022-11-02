# Scripts and workflows to build and update the CFDE portal content registry

## Dependencies

You'll need a modern Python (3.8+) together with snakemake and
cfde-deriva. If you conda/mamba, you can do that with the below:

```
mamba create -n content-reg -c bioconda -y snakemake-minimal
conda activate content-reg
pip install git+https://github.com/nih-cfde/cfde-deriva.git
```

Alternatively, running
```
pip install git+https://github.com/nih-cfde/cfde-deriva.git snakemake
```
should get you there if you're in a Python virtual environment.

## Cloning the repository

Next, clone the repo:

```
git clone https://github.com/nih-cfde/update-content-registry/
```

and change into the repo directory:
```
cd update-content-registry/
```

## Quickstart - building

Then, build!

```
make clean
make
```

## Who can contribute?

Anyone who wants to! Please create pull requests from branches within
this repository; you'll need to ask
[the helpdesk](mailto:support@cfde.atlassian.net) to be added to the
[content-registry-contrib team](https://github.com/orgs/nih-cfde/teams/content-registry-contrib).

## How to add custom content to the registry

The basic idea of the content registry is that for supported
types of controlled vocabulary (CV), each identifier can optionally have
[Markdown](https://www.markdownguide.org/) attached to it. This
Markdown supports text with formatting, tables, images, linkouts, and
iframes; see below for more information on the supported Markdown syntax.

The currently supported CV types are currently `gene`, `anatomy`,
`compound`, and `disease`, although it is straightforward to add
support for other controlled vocabularies used in the C2M2.

### Getting started!

Below is a simple approach to generating your own content that will
let us integrate it other content in the content registry.

(You can see some examples [in the gallery](https://github.com/nih-cfde/update-content-registry/blob/main/docs/gallery.md) if you like!)

The CFDE-CC is happy to help with any of the steps below! Just ask in an
issue!

### FIRST: write a script that builds custom Markdown for one or more CV terms.

The first step is to write some code that builds the requisite Markdown.
The script [scripts/build-appyter-gene-links.py](https://github.com/nih-cfde/update-content-registry/blob/main/scripts/build-appyter-gene-links.py) creates a custom linkout that looks like this:

```
[CFDE Gene Partnership Appyter](https://appyters.maayanlab.cloud/CFDE-Gene-Partnership/#?args.gene={cv_id}&submit)
```

note here that `{cv_id}` is replaced by the identifer for the controlled
vocabulary term - for genes, this is the ENSEMBL ID.

To get started on writing your own Markdown, we suggest

1. making a new branch in this repository
2. copying that script to a new name
3. editing the function `make_markdown` in that script to write slightly
different markdown.

Note that this is just the part we suggest you do to get started -
it's intentionally very simple! But as long as the output of that
script is in the right format, you can have the script itself do
things like connect to a database, load information from other files,
etc.

### SECOND: set up a pull request with your new script against the main branch.

Now add your script to the branch, commit and push to the github
repository.  (You may need to ask for permissions as above.) And then
ask Rayna Harris, Jessica Lumian, and Titus Brown for next steps on slack!

### ADVANCED: add your script to the workflow

Alternatively, you can forge ahead and try to add your script yourself!

Because the content registry may need to aggregate information from
many different Markdown-generating scripts for each term, we built
a workflow to run the scripts first and then aggregate the resulting
Markdown.

We use [snakemake](https://snakemake.readthedocs.io/) for this, and
while you're welcome to look at
[the workflow definition](https://github.com/nih-cfde/update-content-registry/blob/main/Snakefile)
in detail, you don't really need to know snakemake very well at all to
add to it.

In brief, the four things you need to do to add your script into the workflow
are:

1. Make a new rule by copying the whole block starting with `rule gene_json_appyter_link:` and remaining the `appyter_link` part of the name to something else.

2. Change the script name from `scripts/build-appyter-gene-links.py` to whatever you named your script. Here you should also consider running `chmod +x` on the script so that it can be executed directly from the command line.

3. Change the `output` and `params` widget name to something like `05-my-script` (but customized for whatever it is you're doing).

4. Add the output directory name from your new rule to the `gene_json` rule `input:` block.

At this point you should be able to run `make` and have everything build.

The output of your script will be in `output_pieces_gene/05-my-script`
(or whatever you named the output directory). The `.md` files will be
the Markdown, and the `.json` files will be what is uploaded to the
content registry (a JSON dictionary that contains both the markdown
and the specific term ID.)

Once you get to this point, we can do a trial upload of your Markdown
content to the content registry and show you some screenshots, and/or
schedule a Zoom call to talk about next steps.

## Supported Markdown syntax

Content is deposited into the content registry as Markdown, and rendered
using markdown-it with some specialized extensions, some of which are
discussed below.

[The ERMrestJS Markdown documentation](https://github.com/informatics-isi-edu/ermrestjs/blob/master/docs/user-docs/markdown-formatting.md)
is the most complete documentation available for the full set of Markdown
syntax supported by the CFDE portal.  We highlight a few of the specifics
below.

### Tables

Tables are used by the alias table example [in the gallery](https://github.com/nih-cfde/update-content-registry/blob/main/docs/gallery.md).
See the [full supported syntax for tables here](https://github.com/informatics-isi-edu/ermrestjs/blob/master/docs/user-docs/markdown-formatting.md#15-table).

### Iframes

Several of the examples [in the gallery](https://github.com/nih-cfde/update-content-registry/blob/main/docs/gallery.md) use
[iframe HTML elements](https://en.wikipedia.org/wiki/HTML_element#Frames)
to encapsulate calls out to other Web pages.

This uses the `::: iframe` syntax. You can see the full syntax guide
[here](https://github.com/informatics-isi-edu/ermrestjs/blob/master/docs/user-docs/markdown-formatting.md#6-iframe).
