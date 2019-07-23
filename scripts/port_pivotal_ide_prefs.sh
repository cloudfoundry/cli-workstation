#!/usr/bin/env bash
######## USAGE ########
# ~/workspace/cli-workstation/scripts/port_pivotal_ide_prefs.sh

######## ABOUT ########
# Naming these variables in lowercase since they are neither environment nor internal shell variables.
#TODO Replace `echo` messages with a logger when appropriate.

######## FUNCTIONS ########
#TODO Replace global variables with input arguments


copy_prefs_for_subdir() { 
  prefs_subdir_name=$1
  echo "\nFor IDE $ide_dest_dir, copy source prefs subdirectory '$prefs_subdir_name'"

  src_path=$ide_src_path/$prefs_subdir_name
  src_files=$src_path/*
  dest_path=$ide_dest_full_path/config/$prefs_subdir_name
  #echo "Copying $src_path files into $dest_path."

  #TODO Replace this if conditional with a guard 
  if [ -d $src_path ] 
  then
    # Copy source templates to destination config/templates
    mkdir --parents $dest_path # Make parent dir if it does not exist yet

    # --dereference is used to dereference symlinks in source
    echo "cp --update --dereference $src_files $dest_path"
    cp --update --dereference $src_files $dest_path
  fi
}



set -e

ide_prefs_repo=~/workspace/pivotal_ide_prefs
goland_name_in_prefs_repo="Goland"
ide_names=( $goland_name_in_prefs_repo "RubyMine" )

prefs_subdirs=( codestyles keymaps options templates)

# From pivotal_idea_prefs, copy IDE-specific templates folder to <IDE_NAME>/config/templates.
for ide_name in "${ide_names[@]}" ; do
  #### Set source
  ide_src_path=$ide_prefs_repo/pref_sources/$ide_name
  #echo `ls $ide_src_path`

  #### Set destination
  #TODO Dynamically determine destination dir instead of hardcoding IDE version
  if [ $ide_name = "Goland" ]
  then
    ide_name="GoLand"
  fi
  ide_dest_dir=.${ide_name}2019.1
  #echo "$ide_dest_dir"
  ide_dest_full_path=~/$ide_dest_dir
  #echo "IDE destination path: $ide_dest_full_path"

  #### Copy Preferences
  # Copy preferences to the IDE-specific configuration directories
  # i.e. RubyMine has its own destination directory. GoLand has its own, too.
  for subdir_name in "${prefs_subdirs[@]}"; do
    copy_prefs_for_subdir $subdir_name
  done
done


# SELECTED CLEANUP COMMANDS:
# rm -r  /home/pivotal/.GoLand2019.1/config/options
# rm -r  /home/pivotal/.RubyMine2019.1/config/options

# LEARNINGS: 
# -- Avoid using quotes in variable assignment for file paths

# QUESTIONS
# -- Try to understand when you can use bare $ v. ${}

# TESTING
# For /templates => /templates/config
# GoLand: Tab complete Aft
# RubyMine: Tab complete `pl`




