import java.text.*;
import java.util.*;

int nequipes = 30;
int salaireMin = 24123500;
int salaireMax = 189639045;

String[] noms;
String[] codes;
HashMap indices;

ListeSalaires salaires;
ListeClassements classements;


PImage[] logos;
float logow;
float logoh;

static final int HLIGNE = 23;
static final float DEMI_HLIGNE = HLIGNE / 2.0;
static final int BORDS = 60;

int y = 10;       
int spacing = 2; 
int leng = 20; 

int x = 10 ;
int borMax = 445;
int borMin = BORDS+20;

String dateDuJour;
Integrator [] integrator;

String [] calendar = new String[183];
String [] dateRecuva = new String[183];

int jourMax;
int jourMin;
Calendar cal;

int courrant=0;
// Créer un format de date.


DateFormat myFormat = new SimpleDateFormat("yyyyMMdd");
DateFormat frenchCalendar = new SimpleDateFormat("d MMM yyyy");

String dateDebutSaison = "20070401";
String dateFinSaison = "20070930";

void setup() {
  size(520, 760);        

  setupEquipes();
  setupSalaires();
  setupClassements();
  setupLogos();
  setupDates();


  PFont font = loadFont("Sawasdee-Bold-12.vlw");
  textFont(font);

  integrator = new Integrator[nequipes];
  for (int equipe= 0; equipe < nequipes; equipe++) {

    integrator[equipe] =  new Integrator(classements.getRank(equipe) );
  }
}

void draw() {
  background(255);
  smooth();
  translate(BORDS, BORDS);
  float gaucheX = 160;
  float droiteX = 335;
  textAlign(LEFT, CENTER);
  for (int equipe=0; equipe< nequipes; equipe++) {
    integrator[equipe].target(classements.getRank(equipe));
  }
  for (int i=0; i<nequipes; i++) {
    integrator[i].update();
    fill(0);
    float classementY = integrator[i].value * HLIGNE + DEMI_HLIGNE;
    image(logos[i], -20, classementY - logoh/2, logow, logoh);
    text(noms[i], 0, classementY);
    text(classements.getTitle(i), 115, classementY);
    float salaireY = salaires.getRank(i) * HLIGNE + DEMI_HLIGNE;
    float epaisseur=map(salaires.getValue(i), salaireMin, salaireMax, 0.25f, 6);

    strokeWeight(epaisseur);

    float taille=0;
    if (salaireY > classementY) {

      fill(#000000);
      stroke(206, 0, 82);  // Blue
    } else {

      stroke(33, 85, 156);
    }

    line(gaucheX, classementY, droiteX, salaireY);

    text(salaires.getTitle(i), droiteX + 10, salaireY);
  }
  dessinerSelecteur();
}


void setupDates() {
  try {
    Date date1 = myFormat.parse(dateDebutSaison);
    Date date2 = myFormat.parse(dateFinSaison);
    long difference = date2.getTime() - date1.getTime();
    float nombreDejours = (difference / (1000*60*60*24))+1;
    while (date1.before(date2) ) {
      date1 = addDays(date1);  
      calendar[courrant]=(frenchCalendar.format(date1));
      dateRecuva[courrant]=myFormat.format(date1);
      courrant++;
    }
  }
  catch (ParseException e) {
    e.printStackTrace();
  }
}

Date addDays(Date d1) {
  cal = Calendar.getInstance();
  cal.setTime(d1);

  int dateMax = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
  int dateMin = cal.getActualMinimum(Calendar.DAY_OF_MONTH);
  cal.add(Calendar.DATE, 1);

  return cal.getTime();
}


void setupLogos() {
  logos = new PImage[nequipes];
  for (int i=0; i<nequipes; i++) {
    logos[i] = loadImage("small/" + codes[i] + ".gif");
  }
  logow = logos[0].width / 2.0;
  logoh = logos[0].height / 2.0;
}

void setupEquipes() {
  String[] lignes = loadStrings("equipes.tsv");
  nequipes = lignes.length;
  codes = new String[nequipes];
  noms = new String[nequipes];
  indices = new HashMap();

  for (int i = 0; i < nequipes; i++) {
    String[] parties = split(lignes[i], TAB);
    codes[i] = parties[0];
    noms[i] = parties[1];
    indices.put(codes[i], new Integer(i));
  }
}

void setupSalaires() {
  salaires = new ListeSalaires(loadStrings("salaires.tsv"));
}


void setupClassements() {
  classements = new ListeClassements(chargerClassements(2007, 5, 2));
}

int indexEquipe(String code) {
  return ((Integer) indices.get(code)).intValue();
}



String[] chargerClassements(int annee, int mois, int jour) {
  String nom = annee + nf(mois, 2) + nf(jour, 2) + ".tsv";
  String chemin = dataPath(nom);
  File fichier = new File(chemin);
  if ((!fichier.exists()) || (fichier.length() == 0)) {
    // Si le fichier n'existe pas, on le crée à partir de données en ligne.
    // Attention pour cet exemple les années possibles sont entre 1999 et
    // 2011...
    println("on télécharge " + nom);
    PrintWriter writer = createWriter(chemin);
    String base = "http://mlb.mlb.com/components/game" +
      "/year_" + annee + "/month_" + nf(mois, 2) + "/day_" + nf(jour, 2) + "/";
    // American League
    lireClassements(base + "standings_rs_ale.js", writer);
    lireClassements(base + "standings_rs_alc.js", writer);
    lireClassements(base + "standings_rs_alw.js", writer);
    // National League
    lireClassements(base + "standings_rs_nle.js", writer);
    lireClassements(base + "standings_rs_nlc.js", writer);
    lireClassements(base + "standings_rs_nlw.js", writer);

    writer.flush();
    writer.close();
  }
  return loadStrings(chemin);
}




void lireClassements(String fichier, PrintWriter writer) {
  String[] lignes = loadStrings(fichier);
  String code = "";
  int wins = 0;
  int losses = 0;
  for (int i=0; i < lignes.length; i++) {
    String[] matches = match(lignes[i], "\\s+([\\w\\d]+):\\s'(.*)',?");
    if (matches != null) {
      String attr = matches[1];
      String valeur =  matches[2];

      if (attr.equals("code")) {
        code = valeur;
      } else if ( attr.equals("w")) {
        wins = parseInt(valeur);
      } else if (attr.equals("l")) {
        losses = parseInt(valeur);
      }
    } else {
      if (lignes[i].startsWith("}")) {
        // Fin du groupe on écrit les valeurs.
        writer.println(code + TAB + wins + TAB + losses);
      }
    }
  }
}

void dessinerSelecteur() {
  int y = -15;       // 

  int spacing = 2; //distance entre chaque ligne
  int len = 10;     // longueur de chaque ligne

  translate(0, -31);
  Date [] date = new Date[calendar.length];
  for (int x = 20; x <= 183*2+18; x += spacing) { 

    stroke(0);

    line(x, y, x, y + len);
  }
  try {
    if (mouseX>= borMin && mouseX <= borMax && mouseY >= len && mouseY <= len+15) {
      strokeWeight(1);
      stroke(255, 0, 0);
      line(mouseX - BORDS, y, mouseX - BORDS, y+20);
      textAlign(CENTER);
      text(calendar[(mouseX-(BORDS+x+10))/2], mouseX-40, 10);//afficher la date sur le selecteur

      String subStringDate = dateRecuva[(mouseX-(BORDS+x+10))/2];

      //print(Integer.parseInt((subStringDate).substring(0,4))+"\n"+"\n"+Integer.parseInt((subStringDate).substring(4,6))+"\n"+Integer.parseInt((subStringDate).substring(6,8))+"\n");

      if (mousePressed== true) {
        classements = new ListeClassements(chargerClassements(Integer.parseInt((subStringDate).substring(0, 4)), Integer.parseInt((subStringDate).substring(4, 6)), Integer.parseInt((subStringDate).substring(6, 8))));
      }
    }
  }
  catch(Exception e) {
    print("something went wrong with the parsing");
  }
}
