# Démarrage rapide #

[![Build Status](https://secure.travis-ci.org/ezpaarse-project/ezpaarse.png?branch=master)](http://travis-ci.org/ezpaarse-project/ezpaarse)

ezPAARSE se présente sous la forme d'un Web service dans lequel vous pouvez injecter vos logs et récupérer
les évènements de consultation correspondants. Cette procédure décrit comment installer
ezPAARSE sur votre serveur.

## Pré-requis ##

Voici les outils dont vous avez besoin pour faire fonctionner ezPAARSE :

* Système d'exploitation Linux : [voir les pré-requis par systèmes](https://github.com/ezpaarse-project/ezpaarse/blob/master/doc/multi-os.md)
* Outils standards Linux : bash, make, grep, sed ... 
* curl (utilisé par nvm)
* git >= 1.7.10 (pour être compatible avec github)

Remarque : nous préconiserons prochainement un dimensionnement pour le serveur au niveau du CPU et de la RAM.
Pour cela, nous attendons de pouvoir disposer d'un panel de parseurs plus complet pour pouvoir lancer des
benchmarks et en déduire des préconisations matérielles.

## Installation ##

Si vous souhaitez installer une version stable [téléchargez une archives zip ou tar.gz](http://analogist.couperin.org/ezpaarse/download) puis ouvrez un terminal et tapez :
```console
unzip ezpaarse-X.X.X.zip
cd ezpaarse-X.X.X
make
```

Si vous souhaitez installer la version de développement, ouvrez un terminal et tapez :
```console
git clone http://github.com/ezpaarse-project/ezpaarse.git
cd ezpaarse
make
```

Vous avez également la possibilité de [télécharger une archives deb](http://analogist.couperin.org/ezpaarse/download) et de l'installer sur votre système de cette façon :
```console
sudo -E dpkg -i ezpaarse-X.X.X.deb
sudo /etc/init.d/ezpaarse start
```

## Tester l`installation ##

Cette étape vous permettra de valider que votre installation est fonctionnelle.

```console
make start
make test
```

## Usage ##

Des [fichiers de logs exemple et anonymisés](https://raw.github.com/ezpaarse-project/ezpaarse/master/test/dataset/sd.2012-11-30.300.log)
sont disponibles dans les répertoires d'ezPAARSE.

Vous devez tout d'abord vous assurer qu'ezPAARSE est démarré en lançant la commande suivante :

```console
make start
```

Un client HTTP (ici curl) peut envoyer un fichier de données de log (ici ./test/dataset/sd.2012-11-30.300.log)
sur le Web service d'ezPAARSE et obtenir en réponse un flux CSV d'événements de consultation.

```console
curl -X POST http://127.0.0.1:59599/ws/ \
             -v --proxy "" --no-buffer \
             --data-binary @./test/dataset/sd.2012-11-30.300.log
```

Alternativement, vous pouvez également utiliser la commande ``./bin/loginjector`` fournie par ezPAARSE
pour injecter encore plus simplement le fichier de log dans ezPAARSE :

```console
cat ./test/dataset/sd.2012-11-30.300.log | ./bin/loginjector
```
Et enchainer en utilisant la commande ``./bin/csvtotalizer`` fournie par ezPAARSE
pour avoir un aperçu des événements de consultation reconnus par ezPAARSE :

```console
cat ./test/dataset/sd.2012-11-30.300.log | ./bin/loginjector | ./bin/csvtotalizer
```

## Paramétrage avancé ##

* Le port d'écoute du Web service d'ezPAARSE peut être réglé en modifiant la variable ``EZPAARSE_NODEJS_PORT``
dans le fichier ``config.json`` (par défaut 59599)
