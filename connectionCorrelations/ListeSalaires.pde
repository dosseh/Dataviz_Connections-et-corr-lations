class ListeSalaires extends RankedList {
  ListeSalaires(String[] lignes) {
    super(nequipes, false);
    
    for(int i=0; i<nequipes; i++) {
      String parties[] = split(lignes[i], TAB);
      // La première colonne est le code équipe :
      int index = indexEquipe(parties[0]);
      // La seconde colonne est le salaire :
      value[index] = parseInt(parties[1]);
      // On crée une valeur d'affichage au format $NN,NNN,NNN
      // (en anglais les grands nombres sont découpés par des virgules).
      int salaire = (int) value[index];
      title[index] = "$" + nfc(salaire);
    }
    update();
  }
}
