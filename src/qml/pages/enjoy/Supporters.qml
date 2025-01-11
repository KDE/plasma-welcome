/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

ScrollablePage {
    id: root
    heading: i18nc("@title:window", "Supporting Members")
    description: xi18nc("@info:usagetip", "We thank the following supporting members for their recurring donation to KDE:")

    property int sort: 0
    property string filter: ""

    actions: [
        Kirigami.Action {
            displayComponent: QQC2.ComboBox {
                flat: true
                model: [
                    i18nc("@item:inlistbox", "Sort Randomly"),
                    i18nc("@item:inlistbox", "Sort by Name"),
                    i18nc("@item:inlistbox", "Sort by Date")
                ]
                currentIndex: root.sort
                onActivated: root.sort = currentIndex
            }
        },
        Kirigami.Action {
            displayComponent: Kirigami.SearchField {
                width: Kirigami.Units.gridUnit * 10
                placeholderText: i18nc("@label placeholder", "Filter…")
                onAccepted: root.filter = text
            }
        }
    ]

    readonly property var sortedSupporters: {
        switch (sort) {
            case 0:
            default:
                return sortRandom(supporters);
            case 1:
                return sortName(supporters);
            case 2:
                return supporters; // Already sorted by time
        }
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        // Account for scrollbar width
        anchors.horizontalCenterOffset: (flickable.width - root.width) / 2

        source: "favorite"
        width: Kirigami.Units.iconSizes.enormous * 3
        height: Kirigami.Units.iconSizes.enormous * 3
        opacity: 0.05
        z: -100
    }

    view: Flickable {
        id: flickable

        contentWidth: layout.width
        contentHeight: layout.height

        readonly property int margins: Kirigami.Units.gridUnit

        bottomMargin: margins
        leftMargin: margins
        rightMargin: margins
        topMargin: margins

        clip: true

        GridLayout {
            id: layout

            width: flickable.width - flickable.margins * 2
            flow: GridLayout.LeftToRight

            readonly property int minColumnSize: Kirigami.Units.gridUnit * 8

            columns: Math.floor((width - flickable.margins) / (minColumnSize + flickable.margins))

            // HACK: API is considered preview and may be removed in future versions
            // Fixes unequal column widths, as they fill width as the window changes
            // size without gaining or losing columns
            uniformCellWidths: true

            columnSpacing: flickable.margins
            rowSpacing: flickable.margins

            Repeater {
                model: root.sortedSupporters
                delegate: QQC2.Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: modelData

                    visible: root.normalize(text).includes(root.normalize(root.filter))
                }
            }
        }
    }

    function normalize(string) {
        // Decompose code points for comparison, removing accents and converting to lowercase
        // e.g. "Amélie" -> "amelie"
        return string.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    }

    function sortRandom(array) {
        let sorted = array.slice()

        // Fischer-Yates
        for (let i = sorted.length - 1; i > 0; --i) {
            let j = Math.floor(Math.random() * (i + 1));
            let temp = sorted[i];
            sorted[i] = sorted[j];
            sorted[j] = temp;
        }

        return sorted;
    }

    function sortName(array) {
        let sorted = array.slice();

        // Sort by last name, then first name, then middle name
        sorted.sort(function(a, b) {
            let splitA = a.split(" ");
            let splitB = b.split(" ");

            let lastA = splitA.length > 1 ? splitA[splitA.length - 1] : ""
            let lastB = splitB.length > 1 ? splitB[splitB.length - 1] : ""

            if (lastA !== lastB) {
                return lastA.localeCompare(lastB);
            }

            let firstA = splitA[0];
            let firstB = splitB[0];

            if (firstA !== firstB) {
                return firstA.localeCompare(firstB);
            }

            let middleA = splitA.length > 2 ? splitA.slice(1, -1).join(" ") : ""
            let middleB = splitB.length > 2 ? splitB.slice(1, -1).join(" ") : ""

            return middleA.localeCompare(middleB);
        })

        return sorted;
    }

    /*
     * NOTE: Do not modify the following line manually!
     *       Use the provided script instead:
     *           ./UpdateSupporters.py ~/Downloads/rawList.csv
     */
    readonly property var supporters: ["Peter König", "Aurélien COUDERC", "Łukasz Konieczny", "Alexander Gurenko", "Jure Repinc", "Batuhan Taskaya", "Samir Nassar", "Stanislas Leduc", "Nils Martens", "Marius Hergel", "Carl Schwan", "Burgess Chang", "Dennis Zellner", "Martin Beck", "edwin vervliet", "Petr Kadlec", "Gernot Schiller", "Lee Courington", "Sacha Schutz", "Roger Granrud", "Marcos Gutiérrez Alonso", "Chris Niewiarowski", "Denis Doria", "Yu Te Wang", "Jaroslav Reznik", "Diego Miguel Lozano", "Timo Büttner", "Daniel Noga", "Sebastian Paul", "Xuetian Weng", "Antti Luoma", "Kiril Vladimirov", "Odin Vex", "Jeremy Linton", "Guruprasad L", "Christian Gmeiner", "Sergi Navas", "Warren Krettek", "John Kizer", "Lisardo Sobrino", "Peter Nunn", "Carlos Gonzalez Cortes", "Ethan Hussong", "Willow Aran", "Kai-Uwe Uhlitzsch", "Luciano Barea", "Yoann LE TOUCHE", "Wyatt Childers", "Simon Österle", "Andreas Paul", "Martin Supan", "Tom Schwarz", "Titouan Fuchs", "Melissa Autumn", "Oliver Rasche", "Cass Midkiff", "André Barata", "Julius Binder", "Thomas Karpiniec", "Hendrik Richter", "Jakub Judas", "Paul Porubsky", "Harald Gall", "Malte Jürgens", "Cameron Bosch", "Łukasz Plich", "Jack Case", "Ryan Chambers", "Fabian Niepelt", "Michael Stemle", "Jonas Gamao", "Tapio Metsälä", "Alexander Ypema", "Eduard Nikoleisen", "Dean Bradley", "Joshua Phelps", "José Guardado", "Nathan Wolf", "Linda Polman", "Mehrad Mahmoudian", "Curtis Bullock", "Artem Puzikov", "Richard BEOLET", "Björn Bauer", "Paul Worrall", "Régis GUYOMARCH", "Aroun Clément Baudouin-van Os", "Cornelius Kluge", "Paul Fleischer", "Sebastian Löw", "Gerbrand van Dieyen", "Jens Reimann", "Julian Borrero", "Timothy Carr", "Gregor Burgeff", "Michael Brunner", "Johann Jacobsohn", "Andrew Keenan Richardson", "Alexander Verweinen", "Regina Abendroth", "Muthanna K.", "Kevin McCarthy", "Douglas Shaw", "Christopher Mandlbaur", "Joey Eamigh", "Igor Stojkovic", "Rhys Jones", "Paul Birkholtz", "Dima T", "Chad McCullough", "Valentin Petzel", "Lizoblyud Lika", "Byron Fröhlich", "Coty Ternes", "Joan Aluja Oraá", "Jim Crawford", "Jacob Ludvigsen", "Henri Michael", "Helge Bahmann", "Ulrich Schreiner", "Ralf Hein", "Bel Lord-Williams", "Christian Moesgaard", "Simon Hötten", "Dennis Schumann", "Marcus Harrison", "Vincent Delor", "Mustafa Muhammad", "Srikar Gottipati", "Justin Geigley", "Jonas Mutke", "Brett Hagen", "Huw McNamara", "Florian Dittmer", "Samuel Jordan Kleinman", "Jason Logue", "Rob Hyndman", "Dmitry Misharov", "Christoph Singer", "Lukas Neubert", "Lauren Howe", "Lino Moser", "Tristan Remy", "Benjamin Tzschoppe", "Harry A", "Gerardus Franciscus Maria van Iersel", "Thomas Ludwig", "Techin Eamrurksiri", "Pierre-Alexandre Hamel-Bussières", "Philipp Reichmuth", "Thomas Eckart", "Teodor Calin Sirbu", "Benjamin Xiao", "Przemysław Romanik", "Alejandro Cholaquidis", "Kristian Kriehl", "Ian Boll", "Radek Nováček", "Martin Bednar", "scaine uk", "Evan Chang", "Jakob Rath", "Moritz Lammerich", "Neal Gompa", "Chrismettal Binary-6", "Bryan Zaffino", "Angus Kelsey", "Reid Wiggins", "Dirk Holsopple", "Dan Heneise", "Adam Dymitruk", "Peter Simonsson", "ILIOPOULOS IOANNIS", "Zacharie Monnet", "Jan Iversen", "Thomas ROBIN", "Joost Cassee", "Luis Büchi", "Moritz Schulte", "Jed Baldwin", "Nicola Jelmorini", "Lennart Kroll", "Alexander Reimelt", "ali xyz", "Alonso Mendoza", "Dmitry Sobolev", "Eric NGUYEN", "Stefan Neacsu", "Pascal Schmidt", "Arne Keller", "Simon Berz", "Will Butler", "Conny Magnusson", "Tobias Brunner", "Markus Ebner", "Flori G", "Andrew Rosenwinkel", "Paul Merryfellow", "Henning Sextro", "Daan Boerlage", "Tomás Duarte", "William Z", "Cory Adkins", "Marko Hehl", "Mario Loik", "David Germain", "Artur Pieniążek", "Travis Suel", "Milton Hagler", "Alejandro Muñoz Fernández", "Kevin Messer", "Sam Smucny", "Chris Davis", "Vojtech Kuchar", "Pablo Caballero", "Zach B", "Will Styler", "Jay Tuckey", "Ami Chayun", "Sander Smid-Merlijn", "Andrea Scartazza", "OC Blanco", "Nina Wanca", "Andrija Jovanovic", "Dyllan Kobal", "Ivo Marciniak", "Marián Polťák", "Nikita Malgin", "Gaurav Dasharathe", "Zoran Dimovski", "Michael Niehoff", "Tommy Beauclair-Mariotti", "Björn Aili", "David Chocholatý", "David Martinez", "Frank Mankel", "Lars Jose", "Linus Karl", "Kim Hayo", "Achilleas Koutsou", "François-Xavier Thomas", "Renārs Ceļapīters", "Florian Edelmann", "Logan Rogers-Follis", "Boji Tony", "harry loh", "Iain Cuthbertson", "Frédéric LAURENT", "Keelan Jones", "Michel Filipe", "R.A. Bijl", "Stefan Hellwig", "E. Mau.", "Fco Javier Bolívar", "Matt Milliman", "Benjamin Terrier", "Rainier Ramos", "Matija Šuklje", "Daniel Bagge", "Dennis Malmin", "Justus Tartz", "Wolfgang Kerschbaumer", "Dougie Beney", "Mikko Mensonen", "Max Buchholz", "Emanuele Cannizzaro", "Thibaud Franchetti", "your mom", "Florian Stadler", "Luis Garcia", "Miku Hatsune", "George Pchelkin", "Jeremy Winter", "Laust Lund Kristensen", "Aman Chhabra", "Michael Alexsander", "Christoffer Jansson", "Sebastian Goth", "Joshua Mohr", "TIMOPHEY TSITAVETS", "Quentin Stuchlik", "Michael Bolleininger", "JIMI ROSS", "Herbert Feiler", "Paul Elliott", "Nathan Westerman", "Adrian Friedli", "Lukas Kucerik", "Aljosha Papsch", "Bernhard Breinbauer", "Sebastian Fohler", "Andrea Panontin", "Mikołaj Świątek", "Rodney Lorimor", "Jim Helm", "Asim Shrestha", "Tamas Kornman", "Christopher Clarke", "Stephane Perrin", "Bjørnar Hausken", "Peter Permenter", "Christian Strebel", "Michael Winters", "Jérémy Friche", "Andrew Munkres", "Cody Harrison", "Trey Boyer", "Nathaniel Housman", "Sergei Golimbievsky", "Antonio Teixeira", "Gabriel Morell", "Samuel Allen", "Jacob Perron", "David Roth", "Petri Koskimaa", "Niklas Kämper", "Nicola Feltrin", "Jennifer Radtke", "Aleksei Liudskoi", "Sébastien Monassa", "Michael Meister", "Patrick David", "Batuhan Cinar", "Störm Poorun", "Rahul Ramesh", "Nick Severino", "Sebastian Turzanski", "Robert Riemann", "Simon Finlay", "Albert Goncharov", "Mateusz Dytkowski", "Marcel Siggelsten", "Klemen Košir", "Wesley Schroth", "Michal Hlaváč", "Paul McAuley", "Andreas Heinkelein", "Nicolas Rojas", "Daniel Lloyd-Miller", "Paxriel Pax", "Steven Barrett", "Petronio Coelho", "David Gow", "Marijo Mustač", "Alicja Michalska", "Marcel Pierre Simon", "Àlex Magaz Graça", "Michael Schaffner", "Christian Hartmann", "Markus Meier", "Mihail Morosan", "Galin Yordanov", "Mark Woltman", "Angelos Skembris", "Akseli Lahtinen", "Florentin Rack", "Julian Wefers", "Arthur Tadier", "Lenno Nagel", "Grider Li", "Baptiste Rajaut", "Emil Larsson", "Ivan Nack", "Shawn Dunn", "Achim Bohnet", "Eddie Carswell", "Teague Millette", "Tubo Shi", "Dave X", "Rebecca Müller", "Matthew Brunelle", "Isaac Patton", "Mark Marsh", "Sebastian Krönert", "Florian RICHER", "Julian Raschke", "Semen Sobolev", "Alessio Adamo", "Mukilan Thiyagarajan", "Pascal Mages", "Johannes Wolf", "Lorenzo Bicci", "bill morin", "Ryan McCullough", "Julio Moya", "Klaus Wagner", "Jacob Childersmith", "Andrey Melentyev", "Kieren Roberts", "Matheus Ferreira Messias Guedes", "Alistair Bain", "Loïc Bersier", "Robin Slot", "Roberto Michán Sánchez", "Malin Stanescu", "Severin Hamader", "Jaspal Chauhan", "Étienne Pain", "Norbert Spina", "Romain Fleurette", "Monica Ayhens-Madon", "Cristian Le", "Archie Lamb", "William Wojciechowski", "Paulo Dias", "Nicolai Manique", "Jonas Büttner", "Michel van Son", "Ryein Goddard", "Raphael Pretot", "Dennis Körner", "Nicola Mingotti", "Marco Götze", "Jeroen Huijsman", "Jens Erdmann", "Florian Dazinger", "Nathan Pennington", "Arthur Galiullin", "Andre Ramnitz", "Brian Lemons", "Nikolai Eugen Sandvik", "Max Schwarz", "Fred Dickens", "Mitchel Bone", "Victor Castillo", "Manuel Bödder", "Tone Milazzo", "Lukas Hannawald", "Steffen Jasper", "Marco Julian Solanki", "Jonas Hucklenbroich", "Brian Aberts", "Márton Lente", "Sarat Chandra", "Robert Levine", "Patrick Nagel", "Mohammad Rawashdeh", "Andy Meier", "Brendan Foote", "Aaron Bockelie", "ADAM K BIERMAN", "May Doušak", "Stewart Webb", "Ismar Kunic", "Anael González Paz", "Rob Hasselbaum", "Skye Van Valkenburgh", "Benny Fields", "Robert Wolniak", "Szymon Łągiewka", "Lukas Langrock", "Owen Sessiecq", "Stephen Crocker", "José Couto", "Kormos Krisztián", "Jordi Ferrando", "Zhangzhi Hu", "Maarten Bijster", "Janis Bundschu", "Antoni Aloy Torrens", "Valerio Pilo", "Federico Dossena", "Sahan Fernando", "Samega 7Cattac", "Shuyuan Liu", "Brandon Jones", "Ole Solbakken", "Max R", "Adam Szopa", "Bailey Hollis", "Elijah Helms", "Yann Nux", "Zane Godden", "Diego Saavedra Aguirre", "Linghai Yan", "D Ennis", "Hennie Marais", "Christoph Hümbert", "Bob Richter", "Jeroen Tor", "Jeff Cain", "Dino Čobo", "Felix Knecht", "Tony James", "Marco Nelles", "Gleb Sinyavskiy", "Christian Hofstede-Kuhn", "Alexey Andreyev", "Lasse Danegod", "Shayne Johnson", "Brian Marsh", "Bentleigh Beugelaar", "Yishu Wang", "Nicholas Harper", "Matthias Born", "Luis Alvarado", "Dave Lewis", "Nate Coffey", "Jens Churchill", "Long Vu", "Leif-Jöran Olsson", "Edoardo Regni", "Stefan Zurucker-Burda", "Dirk Ziegelmeier", "Brandon Clark", "Mateusz Brdoń", "Luke Renaud", "Solomatin Vladimir", "Ján Trenčanský", "Anthony Beninati", "Petr Tesarik", "Patrick Gianelli", "Gerhard Dittes", "Lukas Skala", "Mikle Kerim", "Jarkko Torvinen", "Daniel Hurtado", "Moritz Füssel", "Witold Sosnowski", "Pjol .", "Turritopsis Dohrnii Teo En Ming", "Robert McCarter", "Philipp Slusallek", "Bernie Innocenti", "Lucas Ji", "Jason Seville", "David Walluscheck", "Costin-Tiberiu Vasilescu", "Vincent Wilms", "Christoph Vollmer", "Tim Blomme", "Jimmy Lindsey", "Francesco Sardara", "Vladimir Baskakov", "Dominik Lux", "Dylan Taylor", "Michael Lelli", "Dominik Viskovic", "Alexandre BROUET", "Alexey Toklovich", "Denis Jovic", "Ivan Sabourin", "Marcin Mikołajczak", "Dmytro Nezhevenko", "Jan De Luyck", "Mark Hiles", "Jonatan Rosenius", "Matthew Orr", "Leander Nachreiner", "Nostre NZ", "Ondřej Vodáček", "Berker Şal", "Bart Otten", "Tasuku Suzuki", "Milas Bowman", "Eve Carletti", "Shingo Ishida", "Moritz Niesen", "Alishams Hassam", "Jarsto van Santen", "Mike Dawson", "Arian Wichmann", "Jacopo Schiavon", "Jan Iversen", "Piotr Gliźniewicz", "Guillaume GAY", "Blair Thiessen", "Ethan Li", "James Fryman", "Riho Kalbus", "Davor Grubisa", "Sandy F", "Rocky Cardwell", "Matthew Cazaly", "Titouan Forgeard", "Daniel Olson", "Jacob Becker", "Grégoire Duvauchelle", "Allen Hazen", "Mischa Zschokke-Gohl", "MD RIDOWAN", "Tim van Osch", "Linus Fell", "Ramón Cahenzli", "Philipp Lohnes", "Rob Goris", "Teemu Vartiainen", "Jon Stelly", "Erik Naprstek", "John Chufar", "Peter Crasta", "Grzegorz Wierzowiecki", "Spencer Sawyer", "Dennis Dalstrøm", "Julien Enselme", "Andrei Ioachim", "Anthony (anthr76) Rabbito", "Amritpal Gill", "Julian Braha", "Bruno Rocha", "Mateusz Albecki", "Florian Klamer", "Merry Mello", "Jörg große Schlarmann", "Matthew Henry", "Achim Königs", "Daniel Zalar", "John McKinney", "Chris Killingsworth", "Gabriel Malo", "Sergio Rodríguez Sansano", "Vojtěch Indrák", "Michael Singer", "Jasmijn Knoope", "Xuanyu Yu", "Alexander Schmitt", "Martín Libedinsky", "Calin Cerghedean", "Peter Strick", "Andres Betts", "Torsten Fratzke", "Kjetil Fjellheim", "Christoffer Jansson", "Samuel Pelz", "Dominik Riedl", "Quentin Guyot", "James North", "Richard Acton", "Ingo Klöcker", "Nathan Misner", "Nick Beaton", "Alma Gottlieb", "Wouter Eerdekens", "Zhaosi Qu", "Steven Naumov", "Zdenek Zikan", "Jan Válek", "David Döring", "Ralf E", "Stephen Rider", "Michal Walach", "Jonathan Verner", "Martín Cigorraga", "Markus Banfi", "Thai Flowers", "Corey Schroeder", "John Huckle", "Frailing Sosa", "Olivier Morneau", "Community Compute LLC", "Éric Gillet", "sergei pavlov", "Alan Gresly", "Herbie Hopkins", "Arjan van Griethuijsen", "Iulian Baciu", "Jan Braun", "Jasmijn Knoope", "zzidun bourbaki", "snow flurry", "Hunor Czaka", "Andrei Zhatkin", "Rodrigo Lourenço", "Pierre van Niekerk", "Marcin Panic", "Kolja Kauer", "AoNeko Yachiyo", "Paul Riley", "Aurélien COUDERC", "Kylie Leach", "Christian McHugh", "Karl Ove Hufthammer", "Yves Soete", "Noah Davis", "Samuel Martin", "Jad El Kik", "Ammon Kent", "Niclas Meick", "Markus Nagel", "Lars Maier", "Alexander Sanderson", "Côme Allart", "昱愷 黃", "Alberto Bec", "Matthias Schade", "Μιχάλης Αντωνόπουλος", "Justin Zobel", "Vincent Roach", "Jeffrey Revock", "Christoph Dreier", "Billy Van Rooy", "Daniel Avilés Hurtado", "Etienne Prud'homme", "Maxime Bernard", "Steve Willard", "Leonhardt Schwarz", "Lee Seymour", "bartosz bialek", "Yannic Schreiber", "Paul Sadauskas", "Klaus Weidenbach", "Piotr Cwieczkowski", "André Matos", "Dieter Rogiest", "Mikko Syrjä", "Samwise Hansen", "Andriy Kushnir", "Matthias Hoffmann", "Ståle Helde", "Aaron Schif", "Jan Wiele", "Sébastien Jaffre", "Karl Quinsland", "Catalina Rosca", "Alistair Francis", "Jason A Holland", "Henning Rohde", "Computer Guy", "Daniel Melin", "Adam Tibbetts", "Lucas Dooms", "Shane Farrell", "Thomas Steffen", "F. Freiwald", "Hauke Winkler", "Oliver Jaksch", "Jean-François ROUX", "Jason Freidman", "Ralf Morgenstern", "Christian Clifford", "Michał Sala", "Stefan Draxlbauer", "Martin Rossbach", "Rocco Tormenta", "Lucas Streanga", "Nicholas Knoblauch", "Darsey Litzenberger", "TrainDoc Last Name", "Florian Schaupp", "Sotiris Papaioannou", "Michael Watzko", "Thomas Chamberlin", "johannes Kehrer", "Stephan Huebner", "Sarah Hillebrand", "Nico Opheys", "Gabriel Shaw Cannabrava", "Alex Ramallo", "Richard Morrill", "james ruggles", "Esmir Lišić", "Thiago Oliveira", "Ravi Rauber", "Devon Goode", "Tobias Theisselmann", "Alex Turner", "Joey Simone", "Ruiqi Niu", "Gökhan Kocak", "Chris Lael", "Martin Eller", "Vincent R", "Albert Backer", "Xian Wang", "Ole V. S. Mortensen", "Tim Büning", "Kai DeLorenzo", "Christoffer Jansson", "Jared Gibson", "Arne Boedt", "Janne Hakonen", "Yosuke Matsumura", "Gytis Ramanauskas", "Rudi Hartinger", "Aaron Ebert", "Antonio de Castro", "Flavio Fearn", "Bastian Veith", "Gene Evans", "Shubham Arora", "Jose Munoz", "Klaus Tusch", "Olivier Roy", "Maximilian Henzl", "Luca Cavana", "Robin Princeley", "Jason Carrete", "Yuriy Zinchuk", "James Coleman", "Gyuwon Seol", "Ronny Kunze", "Gabriele Guarnieri", "James Wilde", "Emilio Cobos", "Saurabh S", "Jan Wameling", "Jonas 595Lab", "Slobodan Halavanja", "Matthew Wong", "João Lucas de Sousa Almeida", "Barry Titterton", "Benjamin Zachry", "William Orrison", "Adam Fidel", "Tobias Hellmann", "Aario Shahbany", "David Drapeau", "Damon Omstead", "Kyle Keefer", "Rüdiger Stenke", "Eric Botter", "Johannes Pfrang", "Jim Rogantini", "Christoffer Jansson", "Victor Elmir", "Johannes Kühnel", "Frank Schiebel", "PGL Porta-Mana", "Olav Seyfarth", "Ben Vidulich", "Utheri Wagura", "Michal Klaus", "Cristian Chiru", "Thorsten Koslowski", "Torsten Gattung", "Erik Fleischer", "Mario Knothe", "Stavros Gero", "Erik Heynekamp", "Samuel Barkley", "Paul Marin", "Torsten Hansen", "Łukasz Nawrot", "Marcin Wolf", "Alexander Kaiser", "Michele Vigilante", "Víctor José Pérez Ruiz", "Eike Neumann", "Josef Drasch", "Bernd Queck", "Jan Radtke", "Andre Peeters", "Anthony REY", "Marco Velten", "Jarl Gjessing", "Victor Boivin", "Antun Horvat", "Bengt Norlander", "Richard Olmsted", "Karl Erik Hofseth", "Dustin Miller", "Giambonini Luca", "Julien Kaspar", "Norbert Langner", "Paul Sobey", "Thomas Franke", "Artur Wala", "Dmytro Skorodenko", "T. Hassing", "sebastian Rampe", "Ábel Nagy", "Sebastian Dornack", "Urs Joss", "Kai Moschcau", "Aleksei Balandin", "James Maxson", "Henrik Nielsen", "Dawid Dziedzic", "ren taotie", "Peter Kryger", "John Fusek", "Pavel Yakunin", "Michael Biel", "Jason Nall", "Thaddeus Hogan", "Mikko Kujala", "Lukas Potthast", "Brandon Rozek", "Omar Luqman", "Rodislav Moldovan", "John Dowling", "Tobias Borgert", "Ulf Saran", "Sigurd Holsen", "Joshua Schmitt", "Parker Dinkelman@hotmail.com", "Ali Zomorodi", "Josh Dix", "Roman Grebennikov", "Marco Fell", "Patrick Groh", "Toxes Foxes", "Jeffrey Zhang", "Robert Donat", "Ionut Leonte", "Luca Junge", "Knut Masanetz", "Marcin Sliwinski", "Martin Bäcker", "Bruno Ribeiro", "Romuald Poteau", "Heinz-Dieter Swiateck", "François Freitag", "Christian Leber", "Olivier Paquien", "Glenn Jenkins", "Kris Gray", "Pontus Mellberg", "Morten Buhl", "Riccardo Ciman", "Félim Whiteley", "Bryan Childs", "Giovanni Tromp", "Jeff Swenson", "Ryan Chew", "Tobias Knöppler", "ZHUOCHENG WANG", "Ole Erik Heins Brennhagen", "Nicholas Jones", "Torsten Römer", "Martin Niemann Madsen", "René Vandamme", "Tim Jagenberg", "Pavel Gejdos", "John Rogers", "Cassandra de la Cruz-Munoz", "Coen Blijker", "Eliseu Amaro", "Nicholas Buckner", "Mark Dietzer", "Lee Pfeifer", "Michał Kubiak", "Anej Budihna", "Nikolai Maziachvili", "Ahmed Khan", "Steve Renz", "Titas Karvelis", "Matthew Standish", "Leonardo Rodoni", "Volker Sachse", "Helmy Saker", "Mark Smith", "Jakub Benda", "AJ Walter", "Maks He", "Tomás Duarte", "Arnaud Dupuis", "Gregg R", "Devin Zuczek", "Alexander Ben Nasrallah", "Joe Dight", "perttu laaksonen", "Muthanna K.", "Skyler Malinowski", "René Schmieding", "Lee Dedear", "Ryan Badgley", "Martin Hopen", "Christoffer Blomvik", "Anton Ch", "Klaus Imfeld", "Ashley Bone", "Marc Collin", "Ben R", "Alexis FLANQUART", "Franz Kuntke", "Dmitry Kagan", "Ludovic Jozeau", "George Galt", "Mark Gabby-Li", "Nicolas Everhart", "Alexandru Octavian Butiu", "Aidan Gauland", "Annette Rios", "Pieta Schofield", "Harald Herrmann", "Mattias Bader", "Ruben Hamelink", "Aidan Fell", "Alex VanBeekum", "mlncn Agaric", "David Fridrich", "Matthew Crowell", "Konstantin Kostov", "Ulrich Müller", "Rolf Wentland", "Iñigo Salvador Azurmendi", "Richard Freitag", "Anastasios Laouros", "Christopher Muller", "Peter Schult", "Ezekiel Littlefield", "Pablo Navarro", "Florian Schaffers", "Hans-Peter Jansen", "Martin Blumenstingl", "Rachel Berkhahn", "Andreas Gocht-Zech", "Florin Alexandru Dicu", "Christian Gruber", "Michael Butler", "Tony Harmelink", "Timothy Le Pés", "Konstantin Pleshakov", "Jan Krause", "Gary Dale", "Jingmin Wang", "Giacomo Moser", "Oleksii Markovets", "Jean-Philippe Carlens", "Remy Genin", "Kevin Fleming", "Morten Lind", "Jean-Luc GOFFLOT", "James Cooper", "Bill Figliolini", "Stefano Badoino", "Balthasar Schlotmann", "Nuno Gomes", "Christophe Burais", "Guennadi Kochelev", "Kilian Schlosser", "Seth Morabito", "Grzegorz Wójcicki", "Harley Napolitano", "Michael Schönitzer", "Justin Lutz", "Enes Selim", "René Sebestian", "Harald Oberhofer", "Andrzej Matuch", "Malte Swart", "Richard Mader"]
}
