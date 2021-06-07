#!/usr/bin/env python3
# coding: utf-8
# Original Author : José DV
# Modified by : wemy (added the arguments options)
import random

# Liste des participants fixe
liste_faces=["Name1", "Name2", "Name3", "Name4", "Name5", "Name6",
             "Name7", "Name8", "Name9", "Name10", "Name11", "Name12",
             "Name13", "Name14", "Name15", "Name16", "Name17"]

# Combien de groupes à constituer ?
nombre_groupes = input("Combien de groupes à constituer ? ")

# Fonction de tirage au sort
def tirage():
    liste_new = []
    for i in range(len(liste_faces)):
        liste_new.append(liste_faces.pop(random.randint(0, len(liste_faces)-1)))
    return liste_new

# Création des tableaux vierges des groupes
for i in range(1, int(nombre_groupes) + 1):
    exec("tableau" + str(i) + "=[]")

# Constitution des groupes
liste_faces = tirage()
compteur = 1
for h in range(len(liste_faces)):
    if compteur > int(nombre_groupes):
        compteur=1
    exec("tableau" + str(compteur) + ".append(liste_faces.pop())")
    compteur += 1

# Affichage des groupes
print()
for i in range(1, int(nombre_groupes)+1):
    print("GROUPE ", i, ": ", eval("tableau"+str(i)))
