# gitflow-py
## This repository contains the GitHub actions to support the Continuous Integration incorporated Branching Strategy (CI-BS) for python package development. 

## Instruction to use this tool:
  1. Make sure your repository has the following branches:
    main
    dev
    release*
    feature*
  2. Make a .github/workflows directory under your repo.
  3. Copy the *gitflow-py-action.yml* from https://github.com/fnlcr-bids-sdsi/gitflow-py into the .github/workflows directory.
  4. Update information at ' image_to_use: "<Replace with your image>" ' line in gitflow-py-action.yml to a GitHub Package address
  5. If you want customed support for actions, please contact us.
 
