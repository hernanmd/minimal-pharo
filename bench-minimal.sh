#! /bin/bash
set -e

name="minimal"
pharo="./pharo"
flags="--no-default-preferences"
pharo_exec="$pharo $name.image $flags eval"
clones_path="repositories"
latest_minimal_name='latest-minimal-64.zip'

clone_repositories() {
    [ -d $clones_path ] || { mkdir $clones_path; }
    [ -d $clones_path/pharo ] || { git clone https://github.com/pharo-project/pharo.git $clones_path; }
    [ -d $clones_path/SMark ] || { git clone https://github.com/guillep/SMark.git $clones_path; }
}

get_pharo_image() {
    [ -e $latest_minimal_name ] || { wget http://files.pharo.org/image/100/$latest_minimal_name; }
    [ -e $latest_minimal_name ] && { unzip -o $latest_minimal_name; }
}

get_pharo_vm() {
    [ -d pharo-vm ] || { wget  -O- https://get.pharo.org/64/vm110 | bash; }
}

# To delete previosuly modified images
delete_image_and_changes() {
    if [ -e $name.image ]; then
        rm $name.image
    fi
    if [ -e $name.changes ]; then
        rm $name.changes
    fi
}

delete_latest_minimal_compressed () {
    [ -f $latest_minimal_name ] && { rm -f $latest_minimal_name; }
}

rename_image_and_changes() {
    local pharo_image=$(find . -maxdepth 1 -name Pharo\*.image)
    local pharo_changes=$(find . -maxdepth 1 -name Pharo\*.changes)

    mv -f "$pharo_image" $name.image
    mv -f "$pharo_changes" $name.changes
    touch PharoV60.sources
}

install_base_packages() {
    ./pharo -headless \
        minimal.image \
        --no-default-preferences \
        metacello install tonel:///$(pwd)/$clones_path/pharo/src BaselineOfSUnit --groups=Core
    ./pharo -headless \
        minimal.image \
        --no-default-preferences \
        metacello install tonel:///$(pwd)/$clones_path/SMark/repository BaselineOfSMark
}

save_image() {
    # cleaning agressively as a last step to ensure image will go down.
    $pharo_exec --save "Smalltalk cleanUp: true except: #() confirming: false"
}

main() {
    clone_repositories
    get_pharo_image
    # delete_image_and_changes
    get_pharo_vm
    rename_image_and_changes
    install_base_packages
    save_image
    delete_latest_minimal_compressed
}

main
