#!/bin/bash

#Author: Nova Solutions
#Description: Script to automate generation archetype
#Last_Modification_Date=28/10/2022

####################################
####### Variables Declaration ######
####################################

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

counter=0
script_version=1.0.1
bc_max_length=36
domain_id_max_length=2
subdomain_id_max_length=2
project_path=${HOME}

DarchetypeGroupId="org.acme"
DarchetypeArtifactId="code-with-quarkus"
DarchetypeVersion="1.0.0-SNAPSHOT"

base_prefix="com.bancoppel"
owner_abbreviation="bcpl"
subdomain_abbreviation="devn"
bounded_context="microservice-ejemplo-naming"
package_sufix_name=""
domain_abbreviation=""

####################################
##### End Variables Declaration ####
####################################

function ctrl_c() {
	echo -e "\n\t${redColour}[!] Saliendo...\n${endColour}"
	tput cnorm
	exit 1
}

function print_micro_types() {
	echo -e "${blueColour}"
	echo "##########################################################"
	echo "                 TIPOS DE MICROSERVICIOS                #"
	echo "##########################################################"
	echo -e "${endColour}${turquoiseColour}\t"
	cat microservices-type.csv
	echo -e "${endColour}"
}

function print_domain_info() {
	echo -e "${blueColour}"
	echo "##########################################################"
	echo "#                 DOMINIOS	    	                 #"
	echo "##########################################################"
	echo -e "${endColour}${turquoiseColour}\t"
	cat domains.csv
	echo -e "${endColour}"
}

function print_subdomain_info() {

	echo -e "${blueColour}"
	echo "##########################################################"
	echo "#                 SUBDOMINIOS		                      #"
	echo "##########################################################"
	echo -e "${endColour}${turquoiseColour}\t"
	tr <subdomains.csv ' ' _ | grep "$domain_abbreviation"
	echo -e "${endColour}"
}

function print_version() {
	echo -e "\n\t${yellowColour}[*]${endColour}${blueColour} Versión -> $script_version ${endColour}\n"
	echo
	echo
	exit 0
}

function helpPanel() {

	echo -e "\n\t\t${yellowColour}*************************************************************${endColour}"
	echo -e "\t\t${yellowColour}****\t\t\t${endColour}${grayColour} Uso de este script  \t\t${endColour}${yellowColour} ****${endColour}"
	echo -e "\t\t${yellowColour}*************************************************************${endColour}"
	echo
	echo -e "\t${yellowColour}Este script automatiza la creación de un microservicio Java solicitando cierta información \n\tlos cuales son:
	\t${purpleColour}- ${endColour}${yellowColour}path del proyecto, donde en caso de que no se especifique se tomará por default la ruta${endColour}${redColour} \"${HOME}\"${endColour}
	\t${purpleColour}- ${endColour}${yellowColour}tipo de microservicio.${endColour}
	\t${purpleColour}- ${endColour}${yellowColour}dominio a utilizar.${endColour}
	\t${purpleColour}- ${endColour}${yellowColour}el nombre del microservicio.
	para poder iniciar utiliza la flag -g${endColour}"
	echo -e "\n\t${yellowColour}Otros flags y su función:\n${endColour}"
	echo -e "\t\t${purpleColour}-h ${endColour}${turquoiseColour}  muestra la ayuda ${endColour}"
	echo -e "\t\t${purpleColour}-g ${endColour}${turquoiseColour}  genera el arquetipo ${endColour}"
	echo -e "\t\t${purpleColour}-t ${endColour}${turquoiseColour}  muestra los tipos de microservicios${endColour}"
	echo -e "\t\t${purpleColour}-d ${endColour}${turquoiseColour}  mustra la información de los dominios${endColour}"
	echo -e "\t\t${purpleColour}-v ${endColour}${turquoiseColour}  muestra la versión de este script${endColour}"
	echo
	exit 1
}

function validate_micro_name() {
	echo -e "${purpleColour}-> ${endColour}${yellowColour}Ingresa el nombre del Microservicio:${endColour}"
	read -r bounded_context
	bounded_context_length=${#bounded_context}
	if [ "$bounded_context_length" -gt $bc_max_length ]; then
		echo -e "\n\t${redColour} Error! ${endColour} ${turquoiseColour}El nombre del microservicio no debe ser mayor a $bc_max_length caracteres.${endColour}"
		echo
		validate_micro_name
	else
		echo -e "${greenColour} >> Nombre del Microservicio correcto${endColour}"

	fi
	package_sufix_name=${bounded_context//[-]/.}
}

function validate_poject_path() {
	echo -e "${purpleColour}-> ${endColour}${yellowColour}Ingresa el path donde se guardara el proyecto generado: ${endColour}${redColour}[default: $HOME]:${endColour}"
	read -r project_path
	if [ "$project_path" != "" ] ; then
	echo -e "\n\t${yellowColour} Advertencia!!! ${endColour} ${turquoiseColour}No se especifico un path, se procede a tomar el path default ${redColour}[default: $HOME]:${endColour}"
		project_path=${HOME}
	fi
	echo
}

function validate_micro_domain() {
	while [ "$counter" -eq 0 ]; do
		echo -e "\n${purpleColour}-> ${endColour}${yellowColour}Ingresa el Id del Dominio: ${endColour}"
		read -r domain_id

		domain_id_length=${#domain_id}

		if [ "$domain_id_length" -eq $domain_id_max_length ]; then
			counter=$(awk -F',' -v csi="$domain_id" '{if($1 == csi)print $1}' domains.csv | wc -l)
		else
			echo -e "\n\t${redColour} Error! ${endColour} ${turquoiseColour}El Id del Dominio debe ser a $domain_id_max_length caracteres.${endColour}"
			validate_micro_domain
		fi

		if [ "$counter" -eq 0 ]; then
			echo -e "\n\t${redColour} Error! ${endColour} ${turquoiseColour} Este no es un Id de Dominio valido, intentalo de nuevo${endColour}"
			validate_micro_domain
		fi
	done
	if [ "$domain_id" != "" ]; then
		domain_abbreviation=$(grep "$domain_id" domains.csv | cut -d ',' -f3 | tr "[:upper:]" "[:lower:]")
		domain_abbreviation=$(echo -e "$domain_abbreviation")
	fi

}

function validate_micro_subdomain() {
	while [ "$counter" -eq 0 ]; do
		echo -e "\n${purpleColour}-> ${endColour}${yellowColour}Ingresa un Id de Subdominio: ${endColour}"
		read -r subdomain_id
		subdomain_id_length=${#subdomain_id}

		if [ "$subdomain_id_length" -eq $subdomain_id_max_length ]; then
			counter=$(awk -F',' -v csi="$subdomain_id_length" '{if($1 == csi)print $1}' domains.csv | wc -l)
		else
			echo -e "\n\t${redColour} Error! ${endColour} ${turquoiseColour}El Id del Subdominio debe ser a $subdomain_id_max_length caracteres.${endColour}"
			validate_micro_subdomain
		fi

		if [ "$counter" -eq 0 ]; then
			echo -e "\n\t${redColour} Error! ${endColour} ${turquoiseColour} Este no es un Id de Subdominio valido, intentalo de nuevo${endColour}"
			validate_micro_subdomain
		fi
	done
	if [ "$domain_id" != "" ]; then
		subdomain_abbreviation=$(grep "$subdomain_id" domains.csv | cut -d ',' -f3 | tr "[:upper:]" "[:lower:]")
		subdomain_abbreviation=$(echo -e "$subdomain_abbreviation")
	fi

}

function validate_micro_type() {
	while [ "$counter" -eq 0 ]; do
		echo -e "\n${purpleColour}-> ${endColour}${yellowColour}Ingresa un tipo de Microservicio: ${endColour}${redColour}[a,b,c,d,e,g,h,o,p,q,t,u,v]:${endColour}"
		read -r acronym
		counter=$(awk -F',' -v mtype="$acronym" '{if($1 == mtype)print $1}' microservices-type.csv | wc -l)
		if [ "$counter" -eq 0 ]; then
			echo -e "\n\t${redColour} Error! ${endColour} ${turquoiseColour}Este no es un tipo de microservicio valido, intentalo de neuvo${endColour}"
			validate_micro_type
		fi
	done
}

function generateArchetype() {

	echo -e "\n\t${purpleColour}>>${endColour}${yellowColour} Generando Arquetipo...${endColour}${purpleColour}<<${endColour}\n"

	validate_poject_path

	validate_micro_name

	print_domain_info

	validate_micro_domain

	counter=0

	print_subdomain_info

	validate_micro_subdomain

	counter=0

	print_micro_types

	validate_micro_type

	artifactId="m$owner_abbreviation-$acronym-$domain_abbreviation-$subdomain_abbreviation-$package_sufix_name"
	groupId="$base_prefix.$acronym.$domain_abbreviation.$subdomain_abbreviation.$package_sufix_name"
	package="$base_prefix.$domain_abbreviation.$subdomain_abbreviation.$package_sufix_name"

	echo
	echo -e "${greenColour}GroupId generado: $groupId "
	echo -e "ArtifactId generado: $artifactId"
	echo -e "Package generado : $package ${endColour}"
	echo

	echo "$project_path"

	cd "$project_path" || exit 1

	mvn archetype:generate -B -DarchetypeGroupId="$DarchetypeGroupId" -DarchetypeArtifactId="$DarchetypeArtifactId" -DarchetypeVersion="$DarchetypeVersion" -DgroupId="$groupId" -DartifactId="$artifactId" -Dversion=1.0.0-SNAPSHOT -Dpackage="$package"

	exit 0
}

# Main Function
while getopts "hgdtv" arg; do
	case $arg in
	h) helpPanel ;;
	g) generateArchetype ;;
	t)
		print_micro_types
		exit 0
		;;
	d)
		print_domain_info
		exit 0
		;;
	v) print_version ;;
	*) helpPanel ;;
	esac
done

if [ $counter -eq 1 ]; then
	echo
else
	echo -e "\n\t\t${redColour} Error! ${endColour} ${turquoiseColour}Se necesita indicar una bandera para poder iniciar.${endColour}"
	helpPanel
fi
