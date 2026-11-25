#pragma once

#include <QString>

// Unde e serverul aplicației (PHP, docs/SCOP.md „Serverul de test”). Un singur loc:
// adresa se schimbă doar aici.
//
// Adresa e a scriptului clientului (ca la UnaWaiter: „.../backend.php”); comanda se
// adaugă de ApiClient ca ?cmd=...
//
// Deocamdată un singur server, cel de test al Etalonus. Mai târziu fiecare client UNA
// are Back-ul și scriptul lui, deci adresa va veni odată cu cardul.
namespace ServerConfig {

inline QString url()
{
    return QStringLiteral("http://una.md:3323/um/una_loyalty/etalonus_test.php");
}

// Cardul al cărui titular apare în Profil, cât nu există intrarea în cont (SMS):
// cardul de test Etalonus „Test Loialitate 2”. Dispare odată cu intrarea în cont.
inline QString testCard()
{
    return QStringLiteral("2803990000023");
}

} // namespace ServerConfig
