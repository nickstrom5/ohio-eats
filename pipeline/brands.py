"""Known chain brands in Ohio: regex on normalized name -> brand label.

Adapted from wi-eats/pipeline/brands.py; Wisconsin-only brands dropped, Colorado and Mountain West chains added (co-eats),
Texas chains added for tx-eats; Michigan chains added for mi-eats (Texas-only ones dropped); Ohio chains added for oh-eats.
"""
import re

BRANDS = [
    ("Dunkin'", r"^DUNKIN"), ("Subway", r"^SUBWAY"), ("McDonald's", r"^MC ?DONALDS"), ("Starbucks", r"^STARBUCK"),
    ("Jimmy John's", r"^JIMMY JOHN"), ("Burger King", r"^BURGER KING"), ("Taco Bell", r"^TACO BELL"),
    ("Potbelly", r"^POTBELLY"), ("Wingstop", r"^WING ?STOP"), ("Chipotle", r"^CHIPOTLE"), ("Popeyes", r"^POPEYE"),
    ("Wendy's", r"^WENDYS"), ("Panda Express", r"^PANDA EXPRESS"), ("White Castle", r"^WHITE CASTLE"),
    ("Chick-fil-A", r"^CHICK FIL"), ("Domino's", r"^DOMINO"), ("Jersey Mike's", r"^JERSEY MIKE"),
    ("Panera Bread", r"^PANERA"), ("Jet's Pizza", r"^JETS PIZZA"), ("Little Caesars", r"^LITTLE CAESAR"),
    ("Papa John's", r"^PAPA JOHN"), ("KFC", r"^KFC|^KENTUCKY FRIED"), ("Tropical Smoothie Cafe", r"^TROPICAL SMOOTHIE"),
    ("Buffalo Wild Wings", r"^BUFFALO WILD"), ("Five Guys", r"^FIVE GUYS"), ("Raising Cane's", r"^RAISING CANE"),
    ("Portillo's", r"^PORTILLO"), ("Auntie Anne's", r"^AUNTIE ANNE"), ("Qdoba", r"^QDOBA"),
    ("Noodles & Company", r"^NOODLES (?:AND )?CO(?:MPANY)?\b"), ("Smoothie King", r"^SMOOTHIE KING"), ("Firehouse Subs", r"^FIREHOUSE SUB"),
    ("IHOP", r"^IHOP"), ("Denny's", r"^DENNYS"), ("Sonic", r"^SONIC DRIVE|^SONIC$"), ("Insomnia Cookies", r"^INSOMNIA COOKIE"),
    ("Crumbl", r"^CRUMBL"), ("Dairy Queen", r"^DAIRY QUEEN|^DQ GRILL|^DQ$"), ("Baskin-Robbins", r"^BASKIN"), ("Krispy Kreme", r"^KRISPY KREME"),
    ("Chuck E. Cheese", r"^CHUCK E CHEESE"), ("Rosati's", r"^ROSATI"), ("Nothing Bundt Cakes", r"^NOTHING BUNDT"),
    ("Hooters", r"^HOOTERS"), ("Cheesecake Factory", r"^CHEESECAKE FACTORY"), ("P.F. Chang's", r"^P ?F CHANG"), ("Maggiano's", r"^MAGGIANO"),
    ("Ruth's Chris", r"^RUTHS CHRIS"), ("Morton's", r"^MORTONS THE STEAK|^MORTONS STEAK"), ("Steak 'n Shake", r"^STEAK N SHAKE"),
    ("Applebee's", r"^APPLEBEE"), ("Chili's", r"^CHILIS"), ("Olive Garden", r"^OLIVE GARDEN"), ("Red Lobster", r"^RED LOBSTER"),
    ("Jamba", r"^JAMBA"), ("Cinnabon", r"^CINNABON"), ("Pizza Hut", r"^PIZZA HUT"), ("Arby's", r"^ARBYS"),
    ("Checkers", r"^CHECKERS DRIVE|^CHECKERS AND RALLY|^CHECKERS$"), ("MOD Pizza", r"^MOD PIZZA"), ("Tim Hortons", r"^TIM HORTON"),
    ("Peet's Coffee", r"^PEETS"), ("Colectivo", r"^COLECTIVO"), ("Cava", r"^CAVA$|^CAVA (?:MEDITERRANEAN|GRILL)"), ("Blaze Pizza", r"^BLAZE PIZZA"),
    # national chains common in Colorado, and Colorado's own
    ("Culver's", r"^CULVER"), ("Taco John's", r"^TACO JOHN"), ("Caribou Coffee", r"^CARIBOU COFFEE|^CARIBOU$"),
    ("Scooter's Coffee", r"^SCOOTERS COFFEE"), ("Dutch Bros", r"^DUTCH BRO"), ("7 Brew", r"^7 BREW"), ("The Human Bean", r"^(?:THE )?HUMAN BEAN"),
    ("Black Rock Coffee", r"^BLACK ROCK COFFEE"), ("Ziggi's Coffee", r"^ZIGGIS"), ("Dazbog Coffee", r"^DAZBOG"),
    ("Texas Roadhouse", r"^TEXAS ROADHOUSE"), ("Famous Dave's", r"^FAMOUS DAVE"), ("Red Robin", r"^RED ROBIN"),
    ("Freddy's", r"^FREDDYS FROZEN|^FREDDYS STEAKBURGER"), ("Papa Murphy's", r"^PAPA MURPH"), ("Marco's Pizza", r"^MARCOS PIZZA"),
    ("Cracker Barrel", r"^CRACKER BARREL"), ("Outback Steakhouse", r"^OUTBACK STEAK"), ("LongHorn Steakhouse", r"^LONGHORN STEAK"),
    ("Cold Stone Creamery", r"^COLD STONE"), ("Golden Corral", r"^GOLDEN CORRAL"),
    ("Old Chicago", r"^OLD CHICAGO$|^OLD CHICAGO (?:PASTA|PIZZA|TAPROOM)"), ("Rock Bottom", r"^ROCK BOTTOM"),
    ("Einstein Bros. Bagels", r"^EINSTEIN BRO"), ("Quiznos", r"^QUIZNO"), ("Fazoli's", r"^FAZOLI"), ("Dickey's Barbecue Pit", r"^DICKEYS"),
    ("HuHot Mongolian Grill", r"^HUHOT"), ("Blimpie", r"^BLIMPIE"), ("Dave's Hot Chicken", r"^DAVES HOT CHICKEN"), ("Sbarro", r"^SBARRO"),
    ("Great Harvest", r"^GREAT HARVEST"), ("Teriyaki Madness", r"^TERIYAKI MADNESS"), ("First Watch", r"^FIRST WATCH"),
    ("TGI Fridays", r"^TGI FRIDAY"), ("Mooyah", r"^MOOYAH"), ("Charleys Cheesesteaks", r"^CHARLEYS"), ("Smashburger", r"^SMASHBURGER"),
    ("Hunt Brothers Pizza", r"^HUNT BROTHERS"), ("Hot Stuff Pizza", r"^HOT STUFF"), ("Krispy Krunchy Chicken", r"^KRISPY KRUNCHY"),
    ("Cheba Hut", r"^CHEBA HUT"), ("MrBeast Burger", r"^MR ?BEAST"), ("It's Just Wings", r"^ITS JUST WINGS"), ("7-Eleven", r"^7 ELEVEN"),
    ("Casey's", r"^CASEYS"), ("Pizza Ranch", r"^PIZZA RANCH"), ("Hardee's", r"^HARDEES"), ("Carl's Jr.", r"^CARLS JR"),
    ("Jack in the Box", r"^JACK IN THE BOX"), ("Del Taco", r"^DEL TACO"), ("Whataburger", r"^WHATABURGER"), ("In-N-Out Burger", r"^IN N OUT"),
    ("Café Rio", r"^CAFE RIO"), ("Costa Vida", r"^COSTA VIDA"), ("Cafe Yumm!", r"^CAFE YUMM"), ("Waffle House", r"^WAFFLE HOUSE"),
    ("Perkins", r"^PERKINS (?:RESTAURANT|BAKERY|AMERICAN|FAMILY)|^PERKINS$"), ("Bob Evans", r"^BOB EVANS"), ("Black Bear Diner", r"^BLACK BEAR DINER"),
    ("Native Grill & Wings", r"^NATIVE GRILL"), ("BJ's Restaurant", r"^BJS RESTAURANT|^BJS BREWHOUSE"), ("Twin Peaks", r"^TWIN PEAKS"),
    ("Kneaders", r"^KNEADERS"), ("Swig", r"^SWIG$"), ("Crave Cookies", r"^CRAVE COOKIE"), ("Paris Baguette", r"^PARIS BAGUETTE"),
    ("Sweetgreen", r"^SWEETGREEN"), ("Torchy's Tacos", r"^TORCHYS"), ("Velvet Taco", r"^VELVET TACO"), ("Fuzzy's Taco Shop", r"^FUZZYS TACO"),
    ("Slim Chickens", r"^SLIM CHICKENS"), ("Zaxby's", r"^ZAXBY"), ("Bojangles", r"^BOJANGLES"), ("Church's Chicken", r"^CHURCHS (?:TEXAS )?CHICKEN"),
    ("Hooters", r"^HOOTERS"), ("Dairy Queen", r"^DAIRY QUEEN|^DQ GRILL|^DQ$"),
    # Colorado-born or Colorado-heavy chains
    ("Illegal Pete's", r"^ILLEGAL PETE"), ("Snarf's", r"^SNARFS"), ("Good Times", r"^GOOD TIMES (?:BURGERS|DRIVE)|^GOOD TIMES$"),
    ("Village Inn", r"^VILLAGE INN"), ("Garbanzo", r"^GARBANZO"), ("Modern Market", r"^MODERN MARKET"), ("Tokyo Joe's", r"^TOKYO JOE"),
    ("Smiling Moose", r"^SMILING MOOSE"), ("Snooze", r"^SNOOZE"), ("Lucile's", r"^LUCILES"), ("Bad Daddy's Burger Bar", r"^BAD DADDYS"),
    ("Mad Greens", r"^MAD GREENS"), ("Larkburger", r"^LARKBURGER"), ("Spicy Pickle", r"^SPICY PICKLE"), ("Sweet Cow", r"^SWEET COW"),
    ("Beau Jo's", r"^BEAU JO"), ("Anthony's Pizza & Pasta", r"^ANTHONYS PIZZA"), ("Blackjack Pizza", r"^BLACKJACK PIZZA"),
    ("Abo's Pizza", r"^ABOS PIZZA|^ABOS$"), ("Woody's Wings", r"^WOODYS WINGS"), ("Fat Shack", r"^FAT SHACK"), ("Wing Shack", r"^WING SHACK"),
    ("Santiago's", r"^SANTIAGOS"), ("Las Delicias", r"^LAS DELICIAS"), ("Tacos y Salsas", r"^TACOS Y SALSAS"), ("Birdcall", r"^BIRDCALL"),
    ("Brothers BBQ", r"^BROTHERS BBQ|^BROTHERS BAR B Q"), ("Moe's Original BBQ", r"^MOES ORIGINAL"), ("Famous Philly's", r"^FAMOUS PHILLYS"),
    ("Biker Jim's", r"^BIKER JIMS"), ("Kaladi Coffee", r"^KALADI"), ("Pablo's Coffee", r"^PABLOS COFFEE"), ("Novo Coffee", r"^NOVO COFFEE"),
    ("Huckleberry Roasters", r"^HUCKLEBERRY ROASTERS"), ("Corvus Coffee", r"^CORVUS"), ("Little Man Ice Cream", r"^LITTLE MAN ICE CREAM"),
    ("Rocky Mountain Chocolate Factory", r"^ROCKY MOUNTAIN CHOCOLATE"), ("Sam's No. 3", r"^SAMS NO 3"), ("Racca's", r"^RACCAS"),
    ("Odell Brewing", r"^ODELL BREWING"), ("New Belgium", r"^NEW BELGIUM"), ("Breckenridge Brewery", r"^BRECKENRIDGE BREWERY"),
    ("Tequila's", r"^TEQUILAS (?:FAMILY )?MEXICAN"), ("El Tapatio", r"^EL TAPATIO"), ("Señor Sol", r"^SENOR SOL"),
    ("Juan's Flying Burrito", r"^JUANS FLYING"), ("Rosie's Diner", r"^ROSIES DINER"), ("Bonchon", r"^BONCHON"), ("Chuy's", r"^CHUYS"),
    ("Kum & Go", r"^KUM (?:AND )?GO"), ("Maverik", r"^MAVERIK"), ("Loaf 'N Jug", r"^LOAF N JUG"), ("Love's", r"^LOVES TRAVEL"),
    # Michigan-born or Michigan-heavy chains (names only; no logos)
    ("Leo's Coney Island", r"^LEOS CONEY"), ("National Coney Island", r"^NATIONAL CONEY"), ("Kerby's Koney Island", r"^KERBYS"),
    ("Coney Island Express", r"^CONEY ISLAND EXPRESS"), ("Buddy's Pizza", r"^BUDDYS PIZZA|^BUDDYS RESTAURANT"), ("Hungry Howie's", r"^HUNGRY HOWIE"),
    ("Cottage Inn Pizza", r"^COTTAGE INN"), ("Mancino's", r"^MANCINOS"), ("Happy's Pizza", r"^HAPPYS PIZZA"), ("Jet's Pizza", r"^JETS PIZZA|^JETS$"),
    ("Shield's", r"^SHIELDS (?:PIZZA|RESTAURANT)"), ("Pizza Sam's", r"^PIZZA SAMS"), ("Big Boy", r"^BIG BOY"), ("Halo Burger", r"^HALO BURGER"),
    ("Olga's Kitchen", r"^OLGAS KITCHEN|^OLGAS$"), ("Biggby Coffee", r"^BIGGBY"), ("Tim Hortons", r"^TIM HORTON"), ("Mr. Pita", r"^MR PITA"),
    ("Penn Station", r"^PENN STATION"), ("Tubby's", r"^TUBBYS"), ("Big Apple Bagels", r"^BIG APPLE BAGEL"), ("Bigalora", r"^BIGALORA"),
    ("Kewpee", r"^KEWPEE"), ("Ram's Horn", r"^RAMS HORN"), ("Bob Evans", r"^BOB EVANS"), ("Senate Coney Island", r"^SENATE CONEY"),
    ("Zingerman's", r"^ZINGERMANS"), ("Sweetwaters Coffee", r"^SWEETWATERS"), 
    ("Grand Traverse Pie Company", r"^GRAND TRAVERSE PIE"), ("Founders Brewing", r"^FOUNDERS BREWING"), ("Bell's", r"^BELLS EAT|^BELLS BREWERY"),
    ("HopCat", r"^HOPCAT"), ("Grand Rapids Brewing", r"^GRAND RAPIDS BREWING"), ("Tony Sacco's", r"^TONY SACCOS"), ("Anna's House", r"^ANNAS HOUSE"),
    ("Panchero's", r"^PANCHEROS"), ("Qdoba", r"^QDOBA"), ("Taco Bob's", r"^TACO BOBS"), ("Moe's Southwest Grill", r"^MOES SOUTHWEST"),
    ("Wings Over", r"^WINGS OVER"), ("BD's Mongolian Barbeque", r"^BDS MONGOLIAN"), 
    ("Meijer", r"^MEIJER"), ("Kroger", r"^KROGER"), ("Speedway", r"^SPEEDWAY"), ("Marathon", r"^MARATHON$|^MARATHON GAS"), ("Wesco", r"^WESCO"),
    ("Family Fare", r"^FAMILY FARE"), ("Shell", r"^SHELL$"), ("Circle K", r"^CIRCLE K"), ("Holiday Stationstores", r"^HOLIDAY STATION"),
    ("Admiral", r"^ADMIRAL (?:PETROLEUM|GAS)"), ("Sheetz", r"^SHEETZ"),
    # Ohio-born or Ohio-heavy chains (names only; no logos)
    ("Skyline Chili", r"^SKYLINE CHILI|^SKYLINE$"), ("Gold Star Chili", r"^GOLD STAR"), ("LaRosa's Pizzeria", r"^LA ?ROSAS"),
    ("Donatos", r"^DONATOS"), ("Marion's Piazza", r"^MARIONS PIAZZA"), ("Cassano's Pizza King", r"^CASSANOS"), ("Swensons", r"^SWENSONS"),
    ("Graeter's", r"^GRAETERS"), ("Handel's", r"^HANDELS"), ("Mitchell's Ice Cream", r"^MITCHELLS (?:HOMEMADE )?ICE CREAM"),
    ("Jeni's Splendid Ice Creams", r"^JENIS"), ("Tony Packo's", r"^TONY PACKOS"), ("Frisch's Big Boy", r"^FRISCHS"),
    ("City Barbeque", r"^CITY BARBEQUE|^CITY BBQ"), ("Condado Tacos", r"^CONDADO"), ("Piada", r"^PIADA"), ("Fusian", r"^FUSIAN"),
    ("Hot Head Burritos", r"^HOT HEAD BURRITO"), ("Charleys Cheesesteaks", r"^CHARLEYS"), ("Max & Erma's", r"^MAX AND ERMAS|^MAX ERMAS"),
    ("Gionino's Pizzeria", r"^GIONINOS"), ("Rascal House Pizza", r"^RASCAL HOUSE"), ("Mr. Hero", r"^MR HERO"), ("Melt Bar & Grilled", r"^MELT BAR"),
    ("Barrio Tacos", r"^BARRIO"), ("Bibibop", r"^BIBIBOP"), ("Massey's Pizza", r"^MASSEYS PIZZA"), ("Pizza Cottage", r"^PIZZA COTTAGE"),
    ("Dewey's Pizza", r"^DEWEYS PIZZA"), ("Montgomery Inn", r"^MONTGOMERY INN"), ("Busken Bakery", r"^BUSKEN"), ("East of Chicago Pizza", r"^EAST OF CHICAGO"),
    ("Romeo's Pizza", r"^ROMEOS PIZZA"), ("Ritter's Frozen Custard", r"^RITTERS"), ("Arthur Treacher's", r"^ARTHUR TREACHER"),
    ("Pies & Pints", r"^PIES AND PINTS"), ("Hot Chicken Takeover", r"^HOT CHICKEN TAKEOVER"), ("Tom + Chee", r"^TOM AND CHEE|^TOM CHEE"),
    ("Old Scratch Pizza", r"^OLD SCRATCH"), ("Ron's Pizza", r"^RONS PIZZA"), ("Snapper's Pizza", r"^SNAPPERS PIZZA"),
    ("Aglamesis Bro's", r"^AGLAMESIS"), ("Buckeye Donuts", r"^BUCKEYE DONUTS"), ("Bob Evans", r"^BOB EVANS"), ("Rax", r"^RAX$|^RAX ROAST"),
    ("Hungry Howie's", r"^HUNGRY HOWIE"), ("Toppers Pizza", r"^TOPPERS"), ("Tim Hortons", r"^TIM HORTON"), ("Biggby Coffee", r"^BIGGBY"),
    ("Eat'n Park", r"^EATN PARK|^EAT N PARK"), ("Quaker Steak & Lube", r"^QUAKER STEAK"), ("Primanti Bros.", r"^PRIMANTI"),
    ("Hoggy's", r"^HOGGYS"), ("Damon's Grill", r"^DAMONS"), ("Champps", r"^CHAMPPS"), ("Mark Pi's", r"^MARK PIS"), ("Panchero's", r"^PANCHEROS"),
    ("Giant Eagle", r"^GIANT EAGLE|^MARKET DISTRICT"), ("GetGo", r"^GET ?GO"), ("United Dairy Farmers", r"^UNITED DAIRY FARMERS|^UDF$"),
    ("Duchess", r"^DUCHESS (?:SHOPPE|GAS)"), ("Dairy Mart", r"^DAIRY MART"), ("Certified Oil", r"^CERTIFIED (?:OIL|GAS)"),
    ("Marc's", r"^MARCS$|^MARCS STORE"), ("Heinen's", r"^HEINENS"), ("Dorothy Lane Market", r"^DOROTHY LANE"), ("Buehler's", r"^BUEHLERS"),
]
_C = [(b, re.compile(p)) for b, p in BRANDS]

# distinctive brands also recognized mid-name ("HALE FAMILY MCDONALDS", "SAII BABA DUNKIN")
_ANYWHERE = [(b, re.compile(p)) for b, p in [("McDonald's", r"\bMC ?DONALDS\b"), ("Dunkin'", r"\bDUNKIN\b"), ("Starbucks", r"\bSTARBUCKS\b"),
             ("Wingstop", r"\bWING ?STOP\b"), ("Culver's", r"\bCULVERS\b"), ("Popeyes", r"\bPOPEYES\b"), ("Chipotle", r"\bCHIPOTLE\b"),
             ("Jimmy John's", r"\bJIMMY JOHNS\b"), ("Taco Bell", r"\bTACO BELL\b"), ("Biggby Coffee", r"\bBIGGBY\b"), ("Tim Hortons", r"\bTIM HORTONS\b")]]


def brand_of(nkey, *more):
    """Brand from the display name, else from Overture's brand label."""
    keys = [k for k in [nkey] + [m for m in more if isinstance(m, str)] if isinstance(k, str)]
    for k in keys:
        for part in [k or ""] + [p.strip() for p in (k or "").split("/")]:
            for b, p in _C:
                if p.search(part):
                    return b
    for k in keys:
        for b, p in _ANYWHERE:
            if p.search(k or ""):
                return b
    return None
