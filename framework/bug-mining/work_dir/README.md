# Overview of patch minimization for commons-configuration and commons-validator

This is a temporary working fork of defects4j repository. We aim to minimize candidate reproducible bugs to the database.

We will minimize the bugs at this fork and `promote-to-db` after we collect all minimization.

Here is the [Patch-Minimization_Guide](https://github.com/rjust/defects4j/blob/master/framework/bug-mining/Patch-Minimization-Guide.md). The default editor for patch minimization is [meld](https://meldmerge.org/). Here is the [requirement for defects4j](https://github.com/rjust/defects4j).

1. Clone this [repository](https://github.com/rrrrrrockpang/defects4j/tree/bug-mining) and checkout the `bug-mining` branch.

2. Make a bare Git repository for commons-configuration and commons-validator. Note that we added the `work_dir` under `bug-mining` folder as the temporary working directory simply to store our progress on the two projects. This is different from the public defects4j repository. 

```
cd $(defects4j_project_dir)/defects4j/framework/bug-mining/work_dir

cd commons-configuration/project_repos
git clone --bare https://github.com/apache/commons-configuration.git
# https://github.com/apache/commons-validator.git
```

3. Navigator to the `run.sh` in `framework/bug-mining` folder

4. In `run.sh`, update the `<bid>` based on the list below. The lists are randomly generated from candidate reproducible bugs after running `get_metadata`. The complete list is under `relevant_tests`.

```
# commons-configuration
# René
64, 70, 72, 76, 77, 78, 84, 124, 131, 133, 134, 137, 141, 147, 151, 164, 166, 173, 184, 189, 203, 213, 259, 264
#
58, 59, 60, 61, 62, 67, 71, 75, 81, 125, 126, 132, 140, 161, 167, 170, 177, 182, 191, 193, 195, 240, 245, 262
#
69, 73, 74, 129, 136, 144, 149, 168, 169, 178, 180, 185, 199, 217, 219, 221, 229, 236, 239, 241, 243, 247, 255
```

```
# commons-validator
# René
20, 27, 56, 58, 62, 65, 66, 76, 81, 85, 89, 90, 93, 99
#
16, 23, 32, 39, 40, 46, 73, 79, 86, 87, 108, 109, 110
#
17, 25, 38, 53, 55, 61, 64, 80, 84, 88, 95, 98, 105
```

Thank you so much!

## Contact:

Rock Pang, ypang2@cs.washington.edu
