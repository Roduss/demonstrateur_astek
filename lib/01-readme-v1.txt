Les 8 fichiers codes doivent �tre organis�s de cette fa�on : 
	size_config dans le dossier lib
	aliment et database_helper dans un dossier "db_utils"
	le reste dans un dossier "screens"


La base de donn�es est accessible au format csv au lien suivant : https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv

Pour acc�der � la base de donn�es sous d'autres format, voir ce lien : https://fr.openfoodfacts.org/data


Version flutter : v1.17.2

Version lbrairies : 

  auto_size_text: ^2.1.0
  intl: ^0.16.1
  shared_preferences: ^0.5.7+3
  sqflite: ^1.3.0+2
  csv: ^4.0.3
  characters : ^1.0.0
  flutter_tts: ^1.2.6
  sqflite: ^1.3.1
  path_provider: ^1.6.10
  intl: ^0.16.1


Voici leur utilit� :
	-main : Page de d�marrage, appairage r�cepteur
	-Accueil : Page d'accueil, avec possibilit� d'acc�der � l'aide, les param�tres et la batterie
	-Help : Page d'aide
	-Settings : Page pour param�trer langue, voix, MAJ auto
	- database_list : Permet d'afficher et modifier le contenu de la BDD
	-aliment : Permet de cr�er une classe de type Aliment
	-database_helper : Permet d'effectuer les op�ration CRUD sur la BDD
	-size_config: Permet de redimensionner rapidemment des Widget

Faire compiler le programme : 
Changer le fichier build.gradle dans android/app/ : 
	minSdkVersion X ==> minSdkVersion 21
(X num�ro version par d�faut)