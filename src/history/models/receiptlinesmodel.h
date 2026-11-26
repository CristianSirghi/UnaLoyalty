#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QtQml/qqmlregistration.h>

// O linie de pe bon: un produs.
struct ReceiptLine
{
    QString name;        // denumirea produsului
    double quantity = 0; // cantitatea (poate fi fracționară: produse la cântar)
    double price = 0;    // prețul unitar, lei (înainte de plata cu puncte)
    double sum = 0;      // suma liniei, lei (înainte de plata cu puncte)
};

// Liniile unui bon, în ordinea de pe bon, de pe server (get_receipt_lines, docs/SCOP.md).
// Bonul se știe după card, casă și numărul lui pe casă:
//   ReceiptLinesModel { barcode: page.barcode; serverId: page.serverId; receiptId: page.receiptId }
// Rândurile au câmpurile name, quantity, price, sum. Cât timp așteaptă răspunsul, loading e
// true; dacă produsele n-au putut fi aduse (ex. casa nu răspunde), failed e true.
class ReceiptLinesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString barcode READ barcode WRITE setBarcode NOTIFY barcodeChanged)
    Q_PROPERTY(int serverId READ serverId WRITE setServerId NOTIFY serverIdChanged)
    Q_PROPERTY(int receiptId READ receiptId WRITE setReceiptId NOTIFY receiptIdChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(bool failed READ failed NOTIFY failedChanged)

public:
    enum Role {
        NameRole = Qt::UserRole + 1,
        QuantityRole,
        PriceRole,
        SumRole,
    };

    explicit ReceiptLinesModel(QObject *parent = nullptr);

    QString barcode() const;
    void setBarcode(const QString &barcode);
    int serverId() const;
    void setServerId(int serverId);
    int receiptId() const;
    void setReceiptId(int receiptId);

    int count() const;
    bool loading() const;
    bool failed() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void barcodeChanged();
    void serverIdChanged();
    void receiptIdChanged();
    void countChanged();
    void loadingChanged();
    void failedChanged();

private:
    void scheduleLoad();
    void load();
    void setLines(const QList<ReceiptLine> &lines);
    void setLoading(bool loading);
    void setFailed(bool failed);

    QString m_barcode;
    int m_serverId = 0;
    int m_receiptId = 0;
    QList<ReceiptLine> m_lines;
    bool m_loading = false;
    bool m_failed = false;
    bool m_loadScheduled = false;
    int m_request = 0;   // crește la fiecare cerere: răspunsurile vechi se ignoră
};
