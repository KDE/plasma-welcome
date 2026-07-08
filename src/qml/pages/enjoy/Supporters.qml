/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome

Welcome.ScrollablePage {
    id: root

    heading: i18nc("@title:window", "Supporting Members")
    description: xi18nc("@info:usagetip", "We thank the following supporting members for their recurring donation to KDE:")

    enum SortOrders {
        Random,
        LastName,
        FirstName,
        Date
    }

    QQC2.ActionGroup {
        id: sortGroup
        exclusive: true
    }

    property int sortOrder: Supporters.SortOrders.Random
    property bool sortReverse: false
    property string filter: ""

    actions: [
        Kirigami.Action {
            text: i18nc("@action:button %1 is the selected sort order, e.g. Random", "Sort: %1", sortGroup.checkedAction.text)
            icon.name: "view-sort-symbolic"

            Kirigami.Action {
                QQC2.ActionGroup.group: sortGroup

                text: i18nc("@action:inmenu An order to sort a list", "Random")
                icon.name: "randomize-symbolic"

                checkable: true
                checked: root.sortOrder === Supporters.SortOrders.Random
                onTriggered: root.sortOrder = Supporters.SortOrders.Random
            }

            Kirigami.Action {
                QQC2.ActionGroup.group: sortGroup

                text: i18nc("@action:inmenu An order to sort a list", "Last Name")
                icon.name: "sort-name-symbolic"

                checkable: true
                checked: root.sortOrder === Supporters.SortOrders.LastName
                onTriggered: root.sortOrder = Supporters.SortOrders.LastName
            }

            Kirigami.Action {
                QQC2.ActionGroup.group: sortGroup

                text: i18nc("@action:inmenu An order to sort a list", "First Name")
                icon.name: "sort-name-symbolic"

                checkable: true
                checked: root.sortOrder === Supporters.SortOrders.FirstName
                onTriggered: root.sortOrder = Supporters.SortOrders.FirstName
            }

            Kirigami.Action {
                QQC2.ActionGroup.group: sortGroup

                text: i18nc("@action:inmenu An order to sort a list, referring to the date a user has first made a donation", "Contribution Date")
                icon.name: "change-date-symbolic"

                checkable: true
                checked: root.sortOrder === Supporters.SortOrders.Date
                onTriggered: root.sortOrder = Supporters.SortOrders.Date
            }

            Kirigami.Action {
                separator: true
            }

            Kirigami.Action {
                text: i18nc("@action:inmenu An option to sort a list in reverse order", "Reverse")
                icon.name: "view-sort-descending-symbolic"

                enabled: root.sortOrder !== Supporters.SortOrders.Random

                checkable: true
                checked: root.sortReverse
                onTriggered: root.sortReverse = checked
            }
        },
        Kirigami.Action {
            displayComponent: Kirigami.SearchField {
                width: Kirigami.Units.gridUnit * 10
                onAccepted: root.filter = text
            }
        }
    ]

    readonly property var sortedSupporters: {
        switch (root.sortOrder) {
            case Supporters.SortOrders.Random:
            default:
                return sortRandom(supporters);
            case Supporters.SortOrders.LastName:
                return sortName(supporters, Supporters.SortOrders.LastName, root.sortReverse);
            case Supporters.SortOrders.FirstName:
                return sortName(supporters, Supporters.SortOrders.FirstName, root.sortReverse);
            case Supporters.SortOrders.Date:
                return sortDate(supporters, root.sortReverse);
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

    function sortName(array, mode, reverse) {
        let sorted = array.slice();

        sorted.sort(function(a, b) {
            // Separate out names
            let splitA = a.split(" ");
            let splitB = b.split(" ");

            let firstA = splitA[0];
            let firstB = splitB[0];

            let lastA = splitA.length > 1 ? splitA[splitA.length - 1] : "";
            let lastB = splitB.length > 1 ? splitB[splitB.length - 1] : "";

            let middleA = splitA.length > 2 ? splitA.slice(1, -1).join(" ") : "";
            let middleB = splitB.length > 2 ? splitB.slice(1, -1).join(" ") : "";

            // Compare using first and last names, in the chosen order
            let primaryCompare = (mode == Supporters.SortOrders.FirstName
                                  ? firstA.localeCompare(firstB) || lastA.localeCompare(lastB)
                                  : lastA.localeCompare(lastB) || firstA.localeCompare(firstB));

            // Fall back on comparing middle names after
            return primaryCompare || middleA.localeCompare(middleB);
        });

        if (reverse) {
            sorted.reverse();
        }

        return sorted;
    }

    function sortDate(array, reverse) {
        let sorted = array.slice();

        // Already sorted by time

        if (reverse) {
            sorted.reverse();
        }

        return sorted;
    }

    /*
     * NOTE: Do not modify the following line manually!
     *       Use the provided script instead:
     *           ./UpdateSupporters.py ~/Downloads/rawList.csv
     *       Ensure you delete this file locally — you should not retain it.
     */
    readonly property var supporters: ["Peter K\u00f6nig", "Aur\u00e9lien COUDERC", "\u0141ukasz Konieczny", "Alexander Gurenko", "Jure Repinc", "Batuhan Taskaya", "Samir Nassar", "Stanislas Leduc", "Nils Martens", "Marius Hergel", "Carl Schwan", "Burgess Chang", "Dennis Zellner", "Martin Beck", "edwin vervliet", "Petr Kadlec", "Gernot Schiller", "Lee Courington", "Sacha Schutz", "Roger Granrud", "Marcos Guti\u00e9rrez Alonso", "Chris Niewiarowski", "Denis Doria", "Yu Te Wang", "Jaroslav Reznik", "Diego Miguel Lozano", "Timo B\u00fcttner", "Daniel Noga", "Sebastian Paul", "Xuetian Weng", "Antti Luoma", "Kiril Vladimirov", "Odin Vex", "Jeremy Linton", "Guruprasad L", "Christian Gmeiner", "Sergi Navas", "Warren Krettek", "John Kizer", "Lisardo Sobrino", "Peter Nunn", "Carlos Gonzalez Cortes", "Ethan Hussong", "Willow Aran", "Kai-Uwe Uhlitzsch", "Luciano Barea", "Yoann LE TOUCHE", "Wyatt Childers", "Simon \u00d6sterle", "Andreas Paul", "Martin Supan", "Tom Schwarz", "Titouan Fuchs", "Melissa Autumn", "Oliver Rasche", "Cass Midkiff", "Andr\u00e9 Barata", "Julius Binder", "Thomas Karpiniec", "Hendrik Richter", "Jakub Judas", "Paul Porubsky", "Harald Gall", "Malte J\u00fcrgens", "Cameron Bosch", "\u0141ukasz Plich", "Jack Case", "Ryan Chambers", "Fabian Niepelt", "Michael Stemle", "Jonas Gamao", "Tapio Mets\u00e4l\u00e4", "Alexander Ypema", "Eduard Nikoleisen", "Dean Bradley", "Joshua Phelps", "Jos\u00e9 Guardado", "Nathan Wolf", "Linda Polman", "Mehrad Mahmoudian", "Curtis Bullock", "Artem Puzikov", "Richard BEOLET", "Bj\u00f6rn Bauer", "Paul Worrall", "R\u00e9gis GUYOMARCH", "Aroun Cl\u00e9ment Baudouin-van Os", "Cornelius Kluge", "Paul Fleischer", "Sebastian L\u00f6w", "Gerbrand van Dieyen", "Jens Reimann", "Julian Borrero", "Timothy Carr", "Gregor Burgeff", "Michael Brunner", "Johann Jacobsohn", "Andrew Keenan Richardson", "Alexander Verweinen", "Regina Abendroth", "Muthanna K.", "Kevin McCarthy", "Douglas Shaw", "Christopher Mandlbaur", "Joey Eamigh", "Igor Stojkovic", "Rhys Jones", "Paul Birkholtz", "Dima T", "Chad McCullough", "Valentin Petzel", "Lizoblyud Lika", "Byron Fr\u00f6hlich", "Coty Ternes", "Joan Aluja Ora\u00e1", "Jim Crawford", "Jacob Ludvigsen", "Henri Michael", "Helge Bahmann", "Ulrich Schreiner", "Ralf Hein", "Bel Lord-Williams", "Christian Moesgaard", "Simon H\u00f6tten", "Dennis Schumann", "Marcus Harrison", "Vincent Delor", "Mustafa Muhammad", "Srikar Gottipati", "Justin Geigley", "Jonas Mutke", "Brett Hagen", "Huw McNamara", "Florian Dittmer", "Samuel Jordan Kleinman", "Jason Logue", "Rob Hyndman", "Dmitry Misharov", "Christoph Singer", "Lukas Neubert", "Lauren Howe", "Lino Moser", "Tristan Remy", "Benjamin Tzschoppe", "Harry A", "Gerardus Franciscus Maria van Iersel", "Thomas Ludwig", "Techin Eamrurksiri", "Pierre-Alexandre Hamel-Bussi\u00e8res", "Philipp Reichmuth", "Thomas Eckart", "Teodor Calin Sirbu", "Benjamin Xiao", "Przemys\u0142aw Romanik", "Alejandro Cholaquidis", "Kristian Kriehl", "Ian Boll", "Radek Nov\u00e1\u010dek", "Martin Bednar", "scaine uk", "Evan Chang", "Jakob Rath", "Moritz Lammerich", "Neal Gompa", "Chrismettal Binary-6", "Bryan Zaffino", "Angus Kelsey", "Reid Wiggins", "Dirk Holsopple", "Dan Heneise", "Adam Dymitruk", "Peter Simonsson", "ILIOPOULOS IOANNIS", "Zacharie Monnet", "Jan Iversen", "Thomas ROBIN", "Joost Cassee", "Luis B\u00fcchi", "Moritz Schulte", "Jed Baldwin", "Nicola Jelmorini", "Lennart Kroll", "Alexander Reimelt", "ali xyz", "Alonso Mendoza", "Dmitry Sobolev", "Eric NGUYEN", "Stefan Neacsu", "Pascal Schmidt", "Arne Keller", "Simon Berz", "Will Butler", "Conny Magnusson", "Tobias Brunner", "Markus Ebner", "Flori G", "Andrew Rosenwinkel", "Paul Merryfellow", "Henning Sextro", "Daan Boerlage", "Tom\u00e1s Duarte", "William Z", "Cory Adkins", "Marko Hehl", "Mario Loik", "David Germain", "Artur Pieni\u0105\u017cek", "Travis Suel", "Milton Hagler", "Alejandro Mu\u00f1oz Fern\u00e1ndez", "Kevin Messer", "Sam Smucny", "Chris Davis", "Vojtech Kuchar", "Pablo Caballero", "Zach B", "Will Styler", "Jay Tuckey", "Ami Chayun", "Sander Smid-Merlijn", "Andrea Scartazza", "OC Blanco", "Nina Wanca", "Andrija Jovanovic", "Dyllan Kobal", "Ivo Marciniak", "Mari\u00e1n Pol\u0165\u00e1k", "Nikita Malgin", "Gaurav Dasharathe", "Zoran Dimovski", "Michael Niehoff", "Tommy Beauclair-Mariotti", "Bj\u00f6rn Aili", "David Chocholat\u00fd", "David Martinez", "Frank Mankel", "Lars Jose", "Linus Karl", "Kim Hayo", "Achilleas Koutsou", "Fran\u00e7ois-Xavier Thomas", "Ren\u0101rs Ce\u013cap\u012bters", "Florian Edelmann", "Logan Rogers-Follis", "Boji Tony", "harry loh", "Iain Cuthbertson", "Fr\u00e9d\u00e9ric LAURENT", "Keelan Jones", "Michel Filipe", "R.A. Bijl", "Stefan Hellwig", "E. Mau.", "Fco Javier Bol\u00edvar", "Matt Milliman", "Benjamin Terrier", "Rainier Ramos", "Matija \u0160uklje", "Daniel Bagge", "Dennis Malmin", "Justus Tartz", "Wolfgang Kerschbaumer", "Dougie Beney", "Mikko Mensonen", "Max Buchholz", "Emanuele Cannizzaro", "Thibaud Franchetti", "your mom", "Florian Stadler", "Luis Garcia", "Miku Hatsune", "George Pchelkin", "Jeremy Winter", "Laust Lund Kristensen", "Aman Chhabra", "Michael Alexsander", "Christoffer Jansson", "Sebastian Goth", "Joshua Mohr", "TIMOPHEY TSITAVETS", "Quentin Stuchlik", "Michael Bolleininger", "JIMI ROSS", "Herbert Feiler", "Paul Elliott", "Nathan Westerman", "Adrian Friedli", "Lukas Kucerik", "Aljosha Papsch", "Bernhard Breinbauer", "Sebastian Fohler", "Andrea Panontin", "Miko\u0142aj \u015awi\u0105tek", "Rodney Lorimor", "Jim Helm", "Asim Shrestha", "Tamas Kornman", "Christopher Clarke", "Stephane Perrin", "Bj\u00f8rnar Hausken", "Peter Permenter", "Christian Strebel", "Michael Winters", "J\u00e9r\u00e9my Friche", "Andrew Munkres", "Cody Harrison", "Trey Boyer", "Nathaniel Housman", "Sergei Golimbievsky", "Antonio Teixeira", "Gabriel Morell", "Samuel Allen", "Jacob Perron", "David Roth", "Petri Koskimaa", "Niklas K\u00e4mper", "Nicola Feltrin", "Jennifer Radtke", "Aleksei Liudskoi", "S\u00e9bastien Monassa", "Michael Meister", "Patrick David", "Batuhan Cinar", "St\u00f6rm Poorun", "Rahul Ramesh", "Nick Severino", "Sebastian Turzanski", "Robert Riemann", "Simon Finlay", "Albert Goncharov", "Mateusz Dytkowski", "Marcel Siggelsten", "Klemen Ko\u0161ir", "Wesley Schroth", "Michal Hlav\u00e1\u010d", "Paul McAuley", "Andreas Heinkelein", "Nicolas Rojas", "Daniel Lloyd-Miller", "Paxriel Pax", "Steven Barrett", "Petronio Coelho", "David Gow", "Marijo Musta\u010d", "Alicja Michalska", "Marcel Pierre Simon", "\u00c0lex Magaz Gra\u00e7a", "Michael Schaffner", "Christian Hartmann", "Markus Meier", "Mihail Morosan", "Galin Yordanov", "Mark Woltman", "Angelos Skembris", "Akseli Lahtinen", "Florentin Rack", "Julian Wefers", "Arthur Tadier", "Lenno Nagel", "Grider Li", "Baptiste Rajaut", "Emil Larsson", "Ivan Nack", "Shawn Dunn", "Achim Bohnet", "Eddie Carswell", "Teague Millette", "Tubo Shi", "Dave X", "Rebecca M\u00fcller", "Matthew Brunelle", "Isaac Patton", "Mark Marsh", "Sebastian Kr\u00f6nert", "Florian RICHER", "Julian Raschke", "Semen Sobolev", "Alessio Adamo", "Mukilan Thiyagarajan", "Pascal Mages", "Johannes Wolf", "Lorenzo Bicci", "bill morin", "Ryan McCullough", "Julio Moya", "Klaus Wagner", "Jacob Childersmith", "Andrey Melentyev", "Kieren Roberts", "Matheus Ferreira Messias Guedes", "Alistair Bain", "Lo\u00efc Bersier", "Robin Slot", "Roberto Mich\u00e1n S\u00e1nchez", "Malin Stanescu", "Severin Hamader", "Jaspal Chauhan", "\u00c9tienne Pain", "Norbert Spina", "Romain Fleurette", "Monica Ayhens-Madon", "Cristian Le", "Archie Lamb", "William Wojciechowski", "Paulo Dias", "Nicolai Manique", "Jonas B\u00fcttner", "Michel van Son", "Ryein Goddard", "Raphael Pretot", "Dennis K\u00f6rner", "Nicola Mingotti", "Marco G\u00f6tze", "Jeroen Huijsman", "Jens Erdmann", "Florian Dazinger", "Nathan Pennington", "Arthur Galiullin", "Andre Ramnitz", "Brian Lemons", "Nikolai Eugen Sandvik", "Max Schwarz", "Fred Dickens", "Mitchel Bone", "Victor Castillo", "Manuel B\u00f6dder", "Tone Milazzo", "Lukas Hannawald", "Steffen Jasper", "Marco Julian Solanki", "Jonas Hucklenbroich", "Brian Aberts", "M\u00e1rton Lente", "Sarat Chandra", "Robert Levine", "Patrick Nagel", "Mohammad Rawashdeh", "Andy Meier", "Brendan Foote", "Aaron Bockelie", "ADAM K BIERMAN", "May Dou\u0161ak", "Stewart Webb", "Ismar Kunic", "Anael Gonz\u00e1lez Paz", "Rob Hasselbaum", "Skye Van Valkenburgh", "Benny Fields", "Robert Wolniak", "Szymon \u0141\u0105giewka", "Lukas Langrock", "Owen Sessiecq", "Stephen Crocker", "Jos\u00e9 Couto", "Kormos Kriszti\u00e1n", "Jordi Ferrando", "Zhangzhi Hu", "Maarten Bijster", "Janis Bundschu", "Antoni Aloy Torrens", "Valerio Pilo", "Federico Dossena", "Sahan Fernando", "Samega 7Cattac", "Shuyuan Liu", "Brandon Jones", "Ole Solbakken", "Max R", "Adam Szopa", "Bailey Hollis", "Elijah Helms", "Yann Nux", "Zane Godden", "Diego Saavedra Aguirre", "Linghai Yan", "D Ennis", "Hennie Marais", "Christoph H\u00fcmbert", "Bob Richter", "Jeroen Tor", "Jeff Cain", "Dino \u010cobo", "Felix Knecht", "Tony James", "Marco Nelles", "Gleb Sinyavskiy", "Christian Hofstede-Kuhn", "Alexey Andreyev", "Lasse Danegod", "Shayne Johnson", "Brian Marsh", "Bentleigh Beugelaar", "Yishu Wang", "Nicholas Harper", "Matthias Born", "Luis Alvarado", "Dave Lewis", "Nate Coffey", "Jens Churchill", "Long Vu", "Leif-J\u00f6ran Olsson", "Edoardo Regni", "Stefan Zurucker-Burda", "Dirk Ziegelmeier", "Brandon Clark", "Mateusz Brdo\u0144", "Luke Renaud", "Solomatin Vladimir", "J\u00e1n Tren\u010dansk\u00fd", "Anthony Beninati", "Petr Tesarik", "Patrick Gianelli", "Gerhard Dittes", "Lukas Skala", "Mikle Kerim", "Jarkko Torvinen", "Daniel Hurtado", "Moritz F\u00fcssel", "Witold Sosnowski", "Pjol .", "Turritopsis Dohrnii Teo En Ming", "Robert McCarter", "Philipp Slusallek", "Bernie Innocenti", "Lucas Ji", "Jason Seville", "David Walluscheck", "Costin-Tiberiu Vasilescu", "Vincent Wilms", "Christoph Vollmer", "Tim Blomme", "Jimmy Lindsey", "Francesco Sardara", "Vladimir Baskakov", "Dominik Lux", "Dylan Taylor", "Michael Lelli", "Dominik Viskovic", "Alexandre BROUET", "Alexey Toklovich", "Denis Jovic", "Ivan Sabourin", "Marcin Miko\u0142ajczak", "Dmytro Nezhevenko", "Jan De Luyck", "Mark Hiles", "Jonatan Rosenius", "Matthew Orr", "Leander Nachreiner", "Nostre NZ", "Ond\u0159ej Vod\u00e1\u010dek", "Berker \u015eal", "Bart Otten", "Tasuku Suzuki", "Milas Bowman", "Eve Carletti", "Shingo Ishida", "Moritz Niesen", "Alishams Hassam", "Jarsto van Santen", "Mike Dawson", "Arian Wichmann", "Jacopo Schiavon", "Jan Iversen", "Piotr Gli\u017aniewicz", "Guillaume GAY", "Blair Thiessen", "Ethan Li", "James Fryman", "Riho Kalbus", "Davor Grubisa", "Sandy F", "Rocky Cardwell", "Matthew Cazaly", "Titouan Forgeard", "Daniel Olson", "Jacob Becker", "Gr\u00e9goire Duvauchelle", "Allen Hazen", "Mischa Zschokke-Gohl", "MD RIDOWAN", "Tim van Osch", "Linus Fell", "Ram\u00f3n Cahenzli", "Philipp Lohnes", "Rob Goris", "Teemu Vartiainen", "Jon Stelly", "Erik Naprstek", "John Chufar", "Peter Crasta", "Grzegorz Wierzowiecki", "Spencer Sawyer", "Dennis Dalstr\u00f8m", "Julien Enselme", "Andrei Ioachim", "Anthony (anthr76) Rabbito", "Amritpal Gill", "Julian Braha", "Bruno Rocha", "Mateusz Albecki", "Florian Klamer", "Merry Mello", "J\u00f6rg gro\u00dfe Schlarmann", "Matthew Henry", "Achim K\u00f6nigs", "Daniel Zalar", "John McKinney", "Chris Killingsworth", "Gabriel Malo", "Sergio Rodr\u00edguez Sansano", "Vojt\u011bch Indr\u00e1k", "Michael Singer", "Jasmijn Knoope", "Xuanyu Yu", "Alexander Schmitt", "Mart\u00edn Libedinsky", "Calin Cerghedean", "Peter Strick", "Andres Betts", "Torsten Fratzke", "Kjetil Fjellheim", "Christoffer Jansson", "Samuel Pelz", "Dominik Riedl", "Quentin Guyot", "James North", "Richard Acton", "Ingo Kl\u00f6cker", "Nathan Misner", "Nick Beaton", "Alma Gottlieb", "Wouter Eerdekens", "Zhaosi Qu", "Steven Naumov", "Zdenek Zikan", "Jan V\u00e1lek", "David D\u00f6ring", "Ralf E", "Stephen Rider", "Michal Walach", "Jonathan Verner", "Mart\u00edn Cigorraga", "Markus Banfi", "Thai Flowers", "Corey Schroeder", "John Huckle", "Frailing Sosa", "Olivier Morneau", "Community Compute LLC", "\u00c9ric Gillet", "sergei pavlov", "Alan Gresly", "Herbie Hopkins", "Arjan van Griethuijsen", "Iulian Baciu", "Jan Braun", "Jasmijn Knoope", "zzidun bourbaki", "snow flurry", "Hunor Czaka", "Andrei Zhatkin", "Rodrigo Louren\u00e7o", "Pierre van Niekerk", "Marcin Panic", "Kolja Kauer", "AoNeko Yachiyo", "Paul Riley", "Aur\u00e9lien COUDERC", "Kylie Leach", "Christian McHugh", "Karl Ove Hufthammer", "Yves Soete", "Noah Davis", "Samuel Martin", "Jad El Kik", "Ammon Kent", "Niclas Meick", "Markus Nagel", "Lars Maier", "Alexander Sanderson", "C\u00f4me Allart", "\u6631\u6137 \u9ec3", "Alberto Bec", "Matthias Schade", "\u039c\u03b9\u03c7\u03ac\u03bb\u03b7\u03c2 \u0391\u03bd\u03c4\u03c9\u03bd\u03cc\u03c0\u03bf\u03c5\u03bb\u03bf\u03c2", "Justin Zobel", "Vincent Roach", "Jeffrey Revock", "Christoph Dreier", "Billy Van Rooy", "Daniel Avil\u00e9s Hurtado", "Etienne Prud'homme", "Maxime Bernard", "Steve Willard", "Leonhardt Schwarz", "Lee Seymour", "bartosz bialek", "Yannic Schreiber", "Paul Sadauskas", "Klaus Weidenbach", "Piotr Cwieczkowski", "Andr\u00e9 Matos", "Dieter Rogiest", "Mikko Syrj\u00e4", "Samwise Hansen", "Andriy Kushnir", "Matthias Hoffmann", "St\u00e5le Helde", "Aaron Schif", "Jan Wiele", "S\u00e9bastien Jaffre", "Karl Quinsland", "Catalina Rosca", "Alistair Francis", "Jason A Holland", "Henning Rohde", "Computer Guy", "Daniel Melin", "Adam Tibbetts", "Lucas Dooms", "Shane Farrell", "Thomas Steffen", "F. Freiwald", "Hauke Winkler", "Oliver Jaksch", "Jean-Fran\u00e7ois ROUX", "Jason Freidman", "Ralf Morgenstern", "Christian Clifford", "Micha\u0142 Sala", "Stefan Draxlbauer", "Martin Rossbach", "Rocco Tormenta", "Lucas Streanga", "Nicholas Knoblauch", "Darsey Litzenberger", "TrainDoc Last Name", "Florian Schaupp", "Sotiris Papaioannou", "Michael Watzko", "Thomas Chamberlin", "johannes Kehrer", "Stephan Huebner", "Sarah Hillebrand", "Nico Opheys", "Gabriel Shaw Cannabrava", "Alex Ramallo", "Richard Morrill", "james ruggles", "Esmir Li\u0161i\u0107", "Thiago Oliveira", "Ravi Rauber", "Devon Goode", "Tobias Theisselmann", "Alex Turner", "Joey Simone", "Ruiqi Niu", "G\u00f6khan Kocak", "Chris Lael", "Martin Eller", "Vincent R", "Albert Backer", "Xian Wang", "Ole V. S. Mortensen", "Tim B\u00fcning", "Kai DeLorenzo", "Christoffer Jansson", "Jared Gibson", "Arne Boedt", "Janne Hakonen", "Yosuke Matsumura", "Gytis Ramanauskas", "Rudi Hartinger", "Aaron Ebert", "Antonio de Castro", "Flavio Fearn", "Bastian Veith", "Gene Evans", "Shubham Arora", "Jose Munoz", "Klaus Tusch", "Olivier Roy", "Maximilian Henzl", "Luca Cavana", "Robin Princeley", "Jason Carrete", "Yuriy Zinchuk", "James Coleman", "Gyuwon Seol", "Ronny Kunze", "Gabriele Guarnieri", "James Wilde", "Emilio Cobos", "Saurabh S", "Jan Wameling", "Jonas 595Lab", "Slobodan Halavanja", "Matthew Wong", "Jo\u00e3o Lucas de Sousa Almeida", "Barry Titterton", "Benjamin Zachry", "William Orrison", "Adam Fidel", "Tobias Hellmann", "Aario Shahbany", "David Drapeau", "Damon Omstead", "Kyle Keefer", "R\u00fcdiger Stenke", "Eric Botter", "Johannes Pfrang", "Jim Rogantini", "Christoffer Jansson", "Victor Elmir", "Johannes K\u00fchnel", "Frank Schiebel", "PGL Porta-Mana", "Olav Seyfarth", "Ben Vidulich", "Utheri Wagura", "Michal Klaus", "Cristian Chiru", "Thorsten Koslowski", "Torsten Gattung", "Erik Fleischer", "Mario Knothe", "Stavros Gero", "Erik Heynekamp", "Samuel Barkley", "Paul Marin", "Torsten Hansen", "\u0141ukasz Nawrot", "Marcin Wolf", "Alexander Kaiser", "Michele Vigilante", "V\u00edctor Jos\u00e9 P\u00e9rez Ruiz", "Eike Neumann", "Josef Drasch", "Bernd Queck", "Jan Radtke", "Andre Peeters", "Anthony REY", "Marco Velten", "Jarl Gjessing", "Victor Boivin", "Antun Horvat", "Bengt Norlander", "Richard Olmsted", "Karl Erik Hofseth", "Dustin Miller", "Giambonini Luca", "Julien Kaspar", "Norbert Langner", "Paul Sobey", "Thomas Franke", "Artur Wala", "Dmytro Skorodenko", "T. Hassing", "sebastian Rampe", "\u00c1bel Nagy", "Sebastian Dornack", "Urs Joss", "Kai Moschcau", "Aleksei Balandin", "James Maxson", "Henrik Nielsen", "Dawid Dziedzic", "ren taotie", "Peter Kryger", "John Fusek", "Pavel Yakunin", "Michael Biel", "Jason Nall", "Thaddeus Hogan", "Mikko Kujala", "Lukas Potthast", "Brandon Rozek", "Omar Luqman", "Rodislav Moldovan", "John Dowling", "Tobias Borgert", "Ulf Saran", "Sigurd Holsen", "Joshua Schmitt", "Parker Dinkelman@hotmail.com", "Ali Zomorodi", "Josh Dix", "Roman Grebennikov", "Marco Fell", "Patrick Groh", "Toxes Foxes", "Jeffrey Zhang", "Robert Donat", "Ionut Leonte", "Luca Junge", "Knut Masanetz", "Marcin Sliwinski", "Martin B\u00e4cker", "Bruno Ribeiro", "Romuald Poteau", "Heinz-Dieter Swiateck", "Fran\u00e7ois Freitag", "Christian Leber", "Olivier Paquien", "Glenn Jenkins", "Kris Gray", "Pontus Mellberg", "Morten Buhl", "Riccardo Ciman", "F\u00e9lim Whiteley", "Bryan Childs", "Giovanni Tromp", "Jeff Swenson", "Ryan Chew", "Tobias Kn\u00f6ppler", "ZHUOCHENG WANG", "Ole Erik Heins Brennhagen", "Nicholas Jones", "Torsten R\u00f6mer", "Martin Niemann Madsen", "Ren\u00e9 Vandamme", "Tim Jagenberg", "Pavel Gejdos", "John Rogers", "Cassandra de la Cruz-Munoz", "Coen Blijker", "Eliseu Amaro", "Nicholas Buckner", "Mark Dietzer", "Lee Pfeifer", "Micha\u0142 Kubiak", "Anej Budihna", "Nikolai Maziachvili", "Ahmed Khan", "Steve Renz", "Titas Karvelis", "Matthew Standish", "Leonardo Rodoni", "Volker Sachse", "Helmy Saker", "Mark Smith", "Jakub Benda", "AJ Walter", "Maks He", "Tom\u00e1s Duarte", "Arnaud Dupuis", "Gregg R", "Devin Zuczek", "Alexander Ben Nasrallah", "Joe Dight", "perttu laaksonen", "Muthanna K.", "Skyler Malinowski", "Ren\u00e9 Schmieding", "Lee Dedear", "Ryan Badgley", "Martin Hopen", "Christoffer Blomvik", "Anton Ch", "Klaus Imfeld", "Ashley Bone", "Marc Collin", "Ben R", "Alexis FLANQUART", "Franz Kuntke", "Dmitry Kagan", "Ludovic Jozeau", "George Galt", "Mark Gabby-Li", "Nicolas Everhart", "Alexandru Octavian Butiu", "Aidan Gauland", "Annette Rios", "Pieta Schofield", "Harald Herrmann", "Mattias Bader", "Ruben Hamelink", "Aidan Fell", "Alex VanBeekum", "mlncn Agaric", "David Fridrich", "Matthew Crowell", "Konstantin Kostov", "Ulrich M\u00fcller", "Rolf Wentland", "I\u00f1igo Salvador Azurmendi", "Richard Freitag", "Anastasios Laouros", "Christopher Muller", "Peter Schult", "Ezekiel Littlefield", "Pablo Navarro", "Florian Schaffers", "Hans-Peter Jansen", "Martin Blumenstingl", "Rachel Berkhahn", "Andreas Gocht-Zech", "Florin Alexandru Dicu", "Christian Gruber", "Michael Butler", "Tony Harmelink", "Timothy Le P\u00e9s", "Konstantin Pleshakov", "Jan Krause", "Gary Dale", "Jingmin Wang", "Giacomo Moser", "Oleksii Markovets", "Jean-Philippe Carlens", "Remy Genin", "Kevin Fleming", "Morten Lind", "Jean-Luc GOFFLOT", "James Cooper", "Bill Figliolini", "Stefano Badoino", "Balthasar Schlotmann", "Nuno Gomes", "Christophe Burais", "Guennadi Kochelev", "Kilian Schlosser", "Seth Morabito", "Grzegorz W\u00f3jcicki", "Harley Napolitano", "Michael Sch\u00f6nitzer", "Justin Lutz", "Enes Selim", "Ren\u00e9 Sebestian", "Harald Oberhofer", "Andrzej Matuch", "Malte Swart", "Florian Hirschhuber", "Richard Mader", "Oriol Tomas", "Catherine Zotova", "Luis Alvarado", "Charles Hollingsworth", "Mick Brun", "Christian Fr\u00f6hlich", "Lukas Polacek", "Efim Nefedov", "Mark Wilson", "Ecen Cronzeton", "Christopher Woods", "Alex Plescan", "Gordon Dexter", "Vladimir Zapparov", "Scott Withrow", "Takahiro Hashimoto", "may meow", "Tyler Dalbora", "Kraus Rene P. P.", "Lukas Kucerik", "Christian H\u00f6lzl", "Rahul Ramesh", "Reuben Parfrey", "Jan Steen", "Ralph Hohmann", "Matthew Vitale", "Raine Liukko", "Alison Chaiken", "Kevin Berkhout", "Carlos Asmat", "Daniel d'Andrada", "Ray Trautman", "Andrei Sebastian C\u00eempean", "Mario Ebenhofer", "Kasper Lind", "Hiyuu Tashiro", "Benedikt Tritschler", "Benjamin Robinson", "Mahendra Tallur", "Nino Pinna", "Thomas Hepp", "Bj\u00f6rn A", "Martin Meinhardt", "Lise Gay", "Matthew Gulliver", "Fabian Ramos", "Jon Atkinson", "Ashley Rezna", "Alex Domingo", "Matvey Ryabchikov", "Alessandro Marigliano", "Peter Wiersig", "Jan Iversen", "Dennis Kibbe", "Christoph Wolkanowski", "Johannes Goller", "Adam Bushell", "Clemente Cuevas", "Sondre Dalen", "Niclas Ro\u00dfberger", "Robert Lake", "Mauro Rocco", "Joel Moore", "Christian Leopoldseder", "David Koch", "Jan Pape\u017e", "JC Polanycia", "Ryan Osborne", "Roman Pyro", "Mira Tamim", "Thomas Braun", "Pascal Herre", "Lawrence Davis", "Karol Pi\u0142at", "Robert Hofmann", "Stephen Ackerman", "Maria Rutaha", "Robin Scholle", "Andrew Bowen", "Peter Johansson", "Sai Rahul Poruri", "Rick Groszkiewicz", "Lo\u00efc Michel", "Tim Okrongli", "Joey Twiddle", "Sameh Sabry", "ismail can g\u00f6kbudak", "Adam Tazul", "Klaus Tusch", "Martin Guillemot", "Chris Wallace", "Karsten Roberts", "Rene Salinas", "Anton Lobashev", "Nathan Upchurch", "Jason Spisak", "Daniel Dvergsnes", "Dani\u00ebl Franke", "Stijn Trommel", "Carlos Morales", "Thomas Schuster", "Nico Bunte", "Amy Kay", "Alexey Abolmasov", "Ari Butterly", "Phillip Gray", "Martin Fl\u00f6ser", "Sebastian Da Silva", "Gonzalo Fernandez", "Keny Chatain", "Michael John Nu\u00f1ez", "Ice Spades", "Neil Baker", "Christian Sommerlund", "Damian Fajfer", "Adri\u00e1n Perales Fern\u00e1ndez", "Micha\u0142 Walenciak", "Sean Borak", "Joseph Gollery LaFournaise", "John Fee", "Seiichi Horie", "Waylon Peng", "Mitchell Hoover", "Markus Schlaffer", "Seiya Ono", "Lennart Koopmann", "Michael Farkas", "Chris Long", "Torsten Fratzke", "Calvin Lang", "James Medlicott", "Artur Simonyants", "Gregorio Troncoso", "Enrique Almi\u00f1ana Magraner", "Janis B", "Markus Gasser", "Rene Lange", "Filip Digr\u00edn", "Gereon Schomber", "Stefan Marotta", "Simon Vinberg Andersen", "Alexander Nolting", "Jairo Benitez", "Lars Ehrhardt", "Jacob Skoog", "Volker Schoenert", "Deepak HS", "Robin Thomas", "Tilo Br\u00fcckner", "Jeremy Lain\u00e9", "Frederik Hoffmann", "Michael Stoll", "Andreas Wagner", "Manfred Mislik", "Niklas Oetken", "Max Brede", "Alexander Gabriel", "Leo Gass", "Hannes Hase", "Adrien Guichard", "Vladimir Serov", "Cary Hughes", "Marco Chines", "Mian Kunze", "Michael Plemmons", "Antonio Caiazzo", "Ubaldo Lopez Bernis", "Henrique Araujo", "Patrick Wu", "Eric Peters", "Roger Powell", "Martin Gei\u00dfler", "Felipe Torrents", "Thomas Wihl", "Harry Mutch", "Daniel Landau", "Pontus Johansson", "Dipesh Patel", "Jesper Palm\u00e9r", "Outi Lauhakangas", "Alan Friedrichsmeyer", "Roman Shaposhnikov", "Jasper de Laat", "Winfried Hofmann", "John Brown", "Konrad Jahn", "Shaan Patel", "Grey Peterson", "Denis Hermann", "Dimitrios Bogiatzoules", "BogDan Vatra", "Miroslav Ondrasina", "Morgan Humes", "Eimantas Bociulis", "Uldis Petersons", "Barkha Herman", "Mark Koenen", "Sjoerd van Leent", "E. Koster", "Eduardo Correia", "Andras Mantia", "Sascha Berner", "Janne Taipalus", "Tino Strau\u00df", "Johannes G\u00fcnther", "Jonathan Bernard", "MArk McKillen", "Ond\u0159ej Hru\u0161ka", "Chuck Ard", "Anders S Danielsen", "Jeremy Fielder", "Mike Eichler", "Thomas Sappl", "Angel Golev", "Martial Saunois", "Tim Burnham", "Simon Will", "Bart Fibrich", "Lucas Schmidt", "Suhas Srinivasan", "Jonathan Fisher", "Martin Thomas", "Christian Skoubye", "Anthony Garratt", "Jonathan Martinez", "Colin Evans", "Julian Espina", "Robert M\u00f6ller", "Michael Dolcimasolo", "George Fountzoulas", "Michael Cormier", "Alex Lienert", "Alex McGinnis", "Adam Luchjenbroers", "Christopher Allan", "Charlie Chan", "Hans-Bernd Dr. Lindemann", "Nicole H\u00e9l\u00e8ne FAURE", "Lars Hollander", "Henry Backman", "Roberto Alfieri", "Christian Hvide J\u00f8rgensen", "Alice Miller", "Arjen Hoekman", "Yousuf Philips", "Mikhail Mutsianko", "Jose Antonio Insua", "laszlo kiss", "Melchizedek Shah", "Jan Meichsner", "Rhys Williams", "Justin Christian", "Karl Friedrich Schulz", "Henrique Borsatto de Campos", "Hayden Schiff", "Brian Diederich", "Kory Byrns", "Neil Redfern", "Arend van Beelen", "Robert Horvath", "Cannon Cloud", "Olli-Pekka Karjalainen", "\u00d8ystein Sture", "Guido Winkelmann", "John Hopper", "Alexander Nikiforov", "Jos\u00e9 Mar\u00eda Gald\u00f3s", "Ulrich Feindt", "Marvin Jahn", "Chris Feigl", "James Spaloss", "Janic Voser", "Aleksandar Jankovi\u0107", "Ennio Barbaro", "Yuen Hoe Lim", "Etienne Bucher", "Lauren Hafford", "Sean Kellner", "Peter Horatschek", "Reinhold Wissing", "Eli Opal", "Aaron Nixon", "Nico St\u00f6we", "Mathias Monse", "Dennis Smith", "Mark Murphy", "Plamen Dimitrov", "Simon Schweighofer", "Guenther Danhofer", "Robert Masterson", "Till Schr\u00f6der", "Jan Koid", "Raphael Walcher", "Matt Van Dyke", "David Zaslavsky", "Sergey Platonov", "Siegfried Meyke", "Hayk Karapetyan", "Mikel Ward", "Sergei Lopatin", "Wian Potgieter", "Francisco Bautista", "Josua Stuber", "Dallin Dyer", "David Knapp", "Marc Baumung", "Santino Mazza", "Christoph Nenning", "Edward Flick", "Martin S\u00e9gur-Cabanac", "Are Egner-Kaupang", "James Dore", "Ionel Ghidarcea", "Dekrit Gampamole", "Kjetil Kilhavn", "Ber Quispel van der Kruijs", "Daniel Larkin-York", "Kyle Lange", "Chris Chapman", "Matthias Bartl", "Derek Bolthausen", "Tom\u00e1\u0161 Hej\u00e1tko", "Tal Shalif", "Elijah Racz", "John Flynn", "Sebastian Voitzsch", "Kendrick Shaw", "Ren\u00e8 Dorfmann", "Maurice Barnich", "Linas Mitkevi\u010dius", "Nishant Kumar", "Bjorn Stange", "Raunak Chhatwal", "Christoper Patti", "James Bland", "Ilias Yacoubi", "Jan Maag", "john athanasiadis", "Danilo Giacomini", "Fran\u00e7ois Delpierre", "Gregor Hilpert", "Matthew Carter", "Christian Locher", "Maximilian H\u00e4cel", "Rebecca Sobol", "Jay L", "Yrj\u00f6 Hatakka", "Brent Maxwell", "Matthias Pfafferodt", "L\u00e1szl\u00f3 K\u00f3kai", "Kevin Steinbach-Reif", "Beat Gerber", "Wolfgang Braun", "Jack Fletcher", "Jordan Crawford", "Esteve Farr\u00e9s", "Carpe Asrael", "Jon Downs", "Christopher Main", "Ralf Engelmann", "Simon Wittwer", "Theo van Rijn", "arjen van drie", "Pascal Jung", "Philip Graham", "Raphael Grieger", "Graham Littlewood", "Jeremy White", "Jeremi Jasinski", "Peter Wesselius", "Heinrich Arnold Witt", "Markus Lauchs", "Howard T", "Alex Billson", "Zachary Wyatt", "Neil Cadman", "Heinrich Schuchardt", "Andrei Khanin", "Karl Johnsson", "Alexander Lagerberg", "Daniel Czapla", "Josemanuel Pastorcampos", "David Gonzalez Rivera", "titouan jezequel", "Luis \"Aragar\" Oliveira", "Aly Raffauf", "Wiktor Zieli\u0144ski", "Samuel Therrien", "Thomas Frach", "Tobias Fellmann", "Jon Iler", "Brandon Lewis", "Max Sickora", "Thomas Gladwin", "Johann Valentin Seeba\u00df", "Martin Schwarz", "Camille Lou\u00e9doc", "Jennifer Linnenberg", "Joaquim Serra", "R\u00e9mi Verschelde", "Mindaugas Sasnauskas", "James Lloyd", "David Sgro", "Daniel Jost", "Keith Connor", "Bogdan Olar", "Christian G", "Tom Berthold", "Adam Gochenour", "Ben Strasser", "Benjamin Ulrich", "Tatiana Mizerova", "Thomas Holder", "Lisa Di Martino", "Michael Leger", "Henry Asbridge", "Patrick Cannon", "William Penrod", "Daniel van den Berg", "Mantas Pocius", "Dan Arrington", "Erlend Furuset Jensen", "Duc Nhat Minh Phan", "An\u017ee \u010casar", "Art Haas", "Valentyn Bykov", "Rodrigo Pelorosso", "Mayank Mehrotra", "Christian Koop", "Andres Reyes", "Michael Cinkus", "rey r", "Fr\u00e9d\u00e9ric Mespl\u00e8de", "Grant Klassy", "Konstantin Queckr", "Jeffrey Stevens", "Seaton Dosher", "Marko Peteri", "Tomislav Karaturovi\u0107", "Jai Clark", "Pirmin Stanglmeier", "Mustafa G\u00fcndo\u011fdu", "Christopher Snowhill", "Lucas Hoy", "Levi Whennen", "Mads Rotwitt", "Zarin Loosli", "Georg Lassnig", "Jonas Larsson", "Ben Wei\u00df", "Philip Grant", "Adon Metcalfe", "Simon Jorzick", "Sascha M\u00f6ller", "Edward Chan", "Thomas Reinhardt", "Martijn Koolhoven", "Alexander Olofsson", "Fabrizio Pelosi", "Felix Urbasik", "Alasdair Stewart", "Daniel Lockhart", "Quentin Gallissot", "MIRZA BOROGOVAC", "Antonios G. Panos", "Timo Paappanen", "Heath Waite", "Martin Fox", "Tiago Saraiva", "Jasper Spit", "Joseph Enders", "Alberico Forgione", "BigMouth TheGreat", "Ulrich Tomaschowski", "ARTEM KULESHOV", "Scott Koch", "Aniruddh Deshpande", "Jakub Jankowski", "Mark Rushing", "Tim Geel", "Tom Kirsch", "Jared Adams", "Gabriel Matos", "Bread Loaf", "Martin Kustra", "Martin James Olminkhof", "Daniel Vr\u0161ek", "Dario Turco", "Sean Clayton", "Mo Gwai", "Elian Manzueta", "Lisa StJohn", "Benedikt Roth", "Justin van Nieuwpoort", "\u00d8jvind Fritjof Arnfred", "Pablo PERNOT", "Thor Aiff", "Marko Vodanovi\u0107", "Ben Strozykowski", "Gianmarco Gargiulo", "Joshua Strobl", "Timothy Wood", "Stefan Lith\u00e9n", "Kit Cox", "Mauri Latvala", "Amy Cheathem", "Guenter Schwann"]
}
