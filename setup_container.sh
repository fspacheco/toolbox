#!/bin/sh

if [ -n "$1" ]; then
   echo "Setting name of toolbox to $1"
   NAME=$1
else
   NAME=dev
   echo "Default name of toolbox is $NAME"
fi

CONTAINERFILE=Container/$NAME
if [ ! -d $CONTAINERFILE ]; then
   printf "Invalid toolbox name, directory $CONTAINERFILE does not exits!\n\n"
   printf "   Valid names are:\n"
   for dir in $(find ./Container/ -maxdepth 1 -mindepth 1 -type d -printf '%P '); do
      printf "    $dir\n"
   done
   exit 1
fi

# Check if container and image exists
podman container list -a | grep $NAME > /dev/null
if [ $? -eq 0 ]; then
   echo "Container named $NAME already exists!"
   while true; do
	read -p "Confirm removal of container ? (y/n): " answer
	case $answer in
		[Yy]* ) break;;     # Continue execution
        	[Nn]* ) exit 1;;    # Stop script
        	* ) echo "Please answer (y)es or (n)o.";;
    	esac
   done
   podman stop $NAME
   podman rm $NAME
fi

podman images | grep $NAME > /dev/null
if [ $? -eq 0 ]; then
   echo "Image localhost/$NAME-toolbox:latest already exists!"
   while true; do
        read -p "Confirm removal of image ? (y/n): " answer
        case $answer in
                [Yy]* ) break;;     # Continue execution
                [Nn]* ) exit 1;;    # Stop script
                * ) echo "Please answer (y)es or (n)o.";;
        esac
   done
   podman rmi localhost/$NAME-toolbox:latest
fi

while true; do
    read -p "Confirm creation of $NAME toolbox ? (y/n): " answer
    case $answer in
        [Yy]* ) break;;     # Continue execution
        [Nn]* ) exit 1;;    # Stop script
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Starting ..."

podman build --squash --tag $NAME-toolbox:latest $CONTAINERFILE
toolbox create -i $NAME-toolbox:latest $NAME
if [ -x $CONTAINERFILE/postbuild.sh ]; then
	podman cp $CONTAINERFILE/postbuild.sh $NAME:/
	toolbox run --container=$NAME /postbuild.sh
	toolbox run --container=$NAME rm /postbuild.sh
fi
