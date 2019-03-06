class ListeClassements extends RankedList {
    ListeClassements(String[] lignes) {
        super(nequipes, false);
        for(int i=0; i<nequipes; i++) {
            String[] parties = split(lignes[i], TAB);
            int index = indexEquipe(parties[0]);
            int wins = parseInt(parties[1]);
            int losses = parseInt(parties[2]);
            value[index] = (float) wins / (float) (wins+losses);
            title[index] = wins + "_" + losses;
        }
        update();
    }
}
