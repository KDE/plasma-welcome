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
    heading: i18nc("@title:window", "Plasma 6 Supporters")
    description: xi18nc("@info:usagetip", "We thank the following people for supporting us during the Plasma 6 fundraising campaign:")

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
                QQC2.Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: modelData
                }

                model: ["Peter König", "Aurélien COUDERC", "Łukasz Konieczny", "Alexander Gurenko", "Jure Repinc", "Batuhan Taskaya", "Samir Nassar", "Stanislas Leduc", "Nils Martens", "Marius Hergel", "Carl Schwan", "Burgess Chang", "Dennis Zellner", "Martin Beck", "edwin vervliet", "Petr Kadlec", "Gernot Schiller", "Lee Courington", "Sacha Schutz", "Roger Granrud", "Marcos Gutiérrez Alonso", "Chris Niewiarowski", "Denis Doria", "Yu Te Wang", "Jaroslav Reznik", "Diego Miguel Lozano", "Timo Büttner", "Daniel Noga", "Sebastian Paul", "Xuetian Weng", "Antti Luoma", "Kiril Vladimirov", "Odin Vex", "Jeremy Linton", "Guruprasad L", "Christian Gmeiner", "Sergi Navas", "Warren Krettek", "John Kizer", "Lisardo Sobrino", "Peter Nunn", "Carlos Gonzalez Cortes", "Ethan Hussong", "Willow Aran", "Kai-Uwe Uhlitzsch", "Luciano Barea", "Yoann LE TOUCHE", "Wyatt Childers", "Simon Österle", "Andreas Paul", "Martin Supan", "Tom Schwarz", "Titouan Fuchs", "Melissa Autumn", "Oliver Rasche", "Cass Midkiff", "André Barata", "Julius Binder", "Thomas Karpiniec", "Hendrik Richter", "Jakub Judas", "Paul Porubsky", "Harald Gall", "Malte Jürgens", "Cameron Bosch", "Łukasz Plich", "Jack Case", "Ryan Chambers", "Fabian Niepelt", "Michael Stemle", "Jonas Gamao", "Tapio Metsälä", "Alexander Ypema", "Eduard Nikoleisen", "Dean Bradley", "Joshua Phelps", "José Guardado", "Nathan Wolf", "Linda Polman", "Mehrad Mahmoudian", "Curtis Bullock", "Artem Puzikov", "Richard BEOLET", "Björn Bauer", "Paul Worrall", "Régis GUYOMARCH", "Aroun Clément Baudouin-van Os", "Cornelius Kluge", "Paul Fleischer", "Sebastian Löw", "Gerbrand van Dieyen", "Jens Reimann", "Julian Borrero", "Timothy Carr", "Gregor Burgeff", "Michael Brunner", "Johann Jacobsohn", "Andrew Keenan Richardson", "Alexander Verweinen", "Regina Abendroth", "Muthanna K.", "Kevin McCarthy", "Douglas Shaw", "Christopher Mandlbaur", "Joey Eamigh", "Igor Stojkovic", "Rhys Jones", "Paul Birkholtz", "Dima T", "Chad McCullough", "Valentin Petzel", "Lizoblyud Lika", "Byron Fröhlich", "Coty Ternes", "Joan Aluja Oraá", "Jim Crawford", "Jacob Ludvigsen", "Henri Michael", "Helge Bahmann", "Ulrich Schreiner", "Ralf Hein", "Bel Lord-Williams", "Christian Moesgaard", "Simon Hötten", "Dennis Schumann", "Marcus Harrison", "Vincent Delor", "Mustafa Muhammad", "Srikar Gottipati", "Justin Geigley", "Jonas Mutke", "Brett Hagen", "Huw McNamara", "Florian Dittmer", "Samuel Jordan Kleinman", "Jason Logue", "Rob Hyndman", "Dmitry Misharov", "Christoph Singer", "Lukas Neubert", "Lauren Howe", "Lino Moser", "Tristan Remy", "Benjamin Tzschoppe", "Harry A", "Gerardus Franciscus Maria van Iersel", "Thomas Ludwig", "Techin Eamrurksiri", "Pierre-Alexandre Hamel-Bussières", "Philipp Reichmuth", "Thomas Eckart", "Teodor Calin Sirbu", "Benjamin Xiao", "Przemysław Romanik", "Denis Doria", "Alejandro Cholaquidis", "Kristian Kriehl", "Ian Boll", "Radek Nováček", "Martin Bednar", "scaine uk", "Evan Chang", "Jakob Rath", "Moritz Lammerich", "Neal Gompa", "Chrismettal Binary-6", "Bryan Zaffino", "Angus Kelsey", "Reid Wiggins", "Dirk Holsopple", "Dan Heneise", "Adam Dymitruk", "Peter Simonsson", "ILIOPOULOS IOANNIS", "Zacharie Monnet", "Jan Iversen", "Thomas ROBIN", "Joost Cassee", "Luis Büchi", "Moritz Schulte", "Jed Baldwin", "Nicola Jelmorini", "Lennart Kroll", "Alexander Reimelt", "ali xyz", "Alonso Mendoza", "Dmitry Sobolev", "Eric NGUYEN", "Stefan Neacsu", "Pascal Schmidt", "Arne Keller", "Simon Berz", "Will Butler", "Conny Magnusson", "Tobias Brunner", "Markus Ebner", "Flori G", "Andrew Rosenwinkel", "Paul Merryfellow", "Henning Sextro", "Daan Boerlage", "Tomás Duarte", "William Z", "Cory Adkins", "Marko Hehl", "Mario Loik", "David Germain", "Artur Pieniążek", "Travis Suel", "Milton Hagler", "Alejandro Muñoz Fernández", "Kevin Messer", "Sam Smucny", "Chris Davis", "Vojtech Kuchar", "Pablo Caballero", "Zach B", "Will Styler", "Jay Tuckey", "Ami Chayun", "Sander Smid-Merlijn", "Andrea Scartazza", "OC Blanco", "Nina Wanca", "Andrija Jovanovic", "Dyllan Kobal", "Ivo Marciniak", "Marián Polťák", "Nikita Malgin", "Gaurav Dasharathe", "Zoran Dimovski", "Michael Niehoff", "Tommy Beauclair-Mariotti", "Björn Aili", "David Chocholatý", "David Martinez", "Frank Mankel", "Lars Jose", "Linus Karl", "Kim Hayo", "Achilleas Koutsou", "François-Xavier Thomas", "Renārs Ceļapīters", "Florian Edelmann", "Boji Tony", "Logan Rogers-Follis", "harry loh", "Iain Cuthbertson", "Frédéric LAURENT", "Keelan Jones", "Michel Filipe", "R.A. Bijl", "Stefan Hellwig", "E. Mau.", "Fco Javier Bolívar", "Matt Milliman", "Benjamin Terrier", "Rainier Ramos", "Matija Šuklje", "Daniel Bagge", "Dennis Malmin", "Justus Tartz", "Wolfgang Kerschbaumer", "Dougie Beney", "Mikko Mensonen", "Max Buchholz", "Emanuele Cannizzaro", "Thibaud Franchetti", "your mom", "Florian Stadler", "Luis Garcia", "Miku Hatsune", "George Pchelkin", "Jeremy Winter", "Laust Lund Kristensen", "Aman Chhabra", "Michael Alexsander", "Christoffer Jansson", "Sebastian Goth", "Joshua Mohr", "TIMOPHEY TSITAVETS", "Quentin Stuchlik", "Michael Bolleininger", "JIMI ROSS", "Herbert Feiler", "Paul Elliott", "Nathan Westerman", "Lukas Kucerik", "Aljosha Papsch", "Bernhard Breinbauer", "Sebastian Fohler", "Andrea Panontin", "Mikołaj Świątek", "Rodney Lorimor", "Jim Helm", "David Martinez", "Asim Shrestha", "Tamas Kornman", "Christopher Clarke", "Bjørnar Hausken", "Peter Permenter", "Christian Strebel"]
            }
        }
    }
}
