#!/usr/bin/env bash
set -e

# ==============================================================================
# ModernQtBrowser v3.0 - Automated Project Generator & Build TUI
# Full Suite: KDE Native UI + SQLite Frecency + Bundles A, B, C, D, E, F & G
# ==============================================================================

PROJECT_DIR="ModernQtBrowser"
QT_WIN_DEFAULT="C:/Qt/6.8.0/msvc2022_64"

# ANSI Colors for Terminal UI
BOLD="\033[1m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET}   $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
err()     { echo -e "${RED}[ERR]${RESET}  $1"; }

# ------------------------------------------------------------------------------
# 1. Scaffold Project Directory & Write All Source Files
# ------------------------------------------------------------------------------
generate_project_files() {
    info "Creating project directory structure at ./${PROJECT_DIR}..."
    mkdir -p "${PROJECT_DIR}/packaging"

    info "Writing CMakeLists.txt (with Qt6::Sql added)..."
    cat << 'EOF' > "${PROJECT_DIR}/CMakeLists.txt"
cmake_minimum_required(VERSION 3.16)
project(ModernQtBrowser VERSION 3.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    Network
    Sql
    PrintSupport
    WebEngineCore
    WebEngineWidgets
)

qt_standard_project_setup()

qt_add_executable(ModernQtBrowser WIN32
    main.cpp
)

target_link_libraries(ModernQtBrowser PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Network
    Qt6::Sql
    Qt6::PrintSupport
    Qt6::WebEngineCore
    Qt6::WebEngineWidgets
)

# Installation Rules
include(GNUInstallDirs)

install(TARGETS ModernQtBrowser
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(UNIX AND NOT APPLE)
    install(FILES packaging/modernqtbrowser.desktop
            DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
    install(FILES packaging/icon.png
            DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps
            RENAME modernqtbrowser.png)
endif()

# Windows Automatic QtWebEngine Deployment
if(WIN32)
    include(InstallRequiredSystemLibraries)

    qt_generate_deploy_app_script(
        TARGET ModernQtBrowser
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endif()

# CPack & NSIS Installer Configuration
set(CPACK_PACKAGE_NAME "ModernQtBrowser")
set(CPACK_PACKAGE_VENDOR "ModernQt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Native Qt6 & KDE Theme Chromium Web Browser v3.0")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/LICENSE.txt")

set(CPACK_PACKAGE_EXECUTABLES "ModernQtBrowser" "ModernQtBrowser")
set(CPACK_CREATE_DESKTOP_LINKS "ModernQtBrowser")

if(WIN32)
    set(CPACK_GENERATOR "NSIS;ZIP")
    set(CPACK_NSIS_DISPLAY_NAME "ModernQtBrowser")
    set(CPACK_NSIS_PACKAGE_NAME "ModernQtBrowser")
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    set(CPACK_NSIS_MODIFY_PATH OFF)
endif()

include(CPack)
EOF

    info "Writing full-featured v3.0 main.cpp (Bundles A through G integrated)..."
    cat << 'EOF' > "${PROJECT_DIR}/main.cpp"
#include <QApplication>
#include <QMainWindow>
#include <QTabWidget>
#include <QTabBar>
#include <QToolBar>
#include <QToolButton>
#include <QLineEdit>
#include <QCompleter>
#include <QStandardItemModel>
#include <QStandardItem>
#include <QProgressBar>
#include <QStatusBar>
#include <QDockWidget>
#include <QListWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QLabel>
#include <QFileDialog>
#include <QMessageBox>
#include <QDialog>
#include <QClipboard>
#include <QDesktopServices>
#include <QSplitter>
#include <QSettings>
#include <QDateTime>
#include <QShortcut>
#include <QStyle>
#include <QPalette>
#include <QEvent>
#include <QCloseEvent>
#include <QPoint>
#include <QUrl>
#include <QUrlQuery>
#include <QRegularExpression>
#include <QAction>
#include <QMenu>
#include <QSet>
#include <QMap>
#include <QStack>
#include <QTimer>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>
#include <QTextStream>
#include <QReadWriteLock>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <atomic>

#include <QWebEngineView>
#include <QWebEnginePage>
#include <QWebEngineProfile>
#include <QWebEngineSettings>
#include <QWebEngineHistory>
#include <QWebEngineDownloadRequest>
#include <QWebEngineFullScreenRequest>
#include <QWebEngineUrlRequestInterceptor>
#include <QWebEngineUrlRequestInfo>
#include <QWebEngineScript>
#include <QWebEngineScriptCollection>
#include <QWebEngineCookieStore>

#if QT_VERSION >= QT_VERSION_CHECK(6, 8, 0)
#include <QWebEnginePermission>
#endif

class BrowserWindow;

// ----------------------------------------------------------------------------
// Network-Level Ad & Tracker Blocker with EasyList & Per-Site Whitelist
// ----------------------------------------------------------------------------
class AdBlockInterceptor : public QWebEngineUrlRequestInterceptor {
    Q_OBJECT
public:
    explicit AdBlockInterceptor(QObject *parent = nullptr)
        : QWebEngineUrlRequestInterceptor(parent),
          m_netManager(new QNetworkAccessManager(this)) {

        m_blockedDomains = {
            "doubleclick.net", "googlesyndication.com", "googleadservices.com",
            "google-analytics.com", "googletagmanager.com", "adnxs.com",
            "taboola.com", "outbrain.com", "scorecardresearch.com", "criteo.com"
        };

        initCacheAndSync();
    }

    void setEnabled(bool enabled) { m_enabled.store(enabled, std::memory_order_relaxed); }
    bool isEnabled() const { return m_enabled.load(std::memory_order_relaxed); }
    int blockedCount() const { return m_blockedCount.load(std::memory_order_relaxed); }

    // Bundle E: Per-Site Whitelist Management
    void setUserWhitelist(const QSet<QString> &domains) {
        QWriteLocker writeLocker(&m_lock);
        m_userWhitelist = domains;
    }

    bool toggleWhitelistDomain(const QString &rawHost) {
        const QString domain = registeredDomain(rawHost.toLower());
        if (domain.isEmpty()) return false;
        QWriteLocker writeLocker(&m_lock);
        if (m_userWhitelist.contains(domain)) {
            m_userWhitelist.remove(domain);
            return false;
        } else {
            m_userWhitelist.insert(domain);
            return true;
        }
    }

    bool isSiteWhitelisted(const QString &rawHost) const {
        QReadLocker locker(&m_lock);
        return matchesDomainSet(rawHost.toLower(), m_userWhitelist);
    }

    void updateFilterLists() {
        const QUrl easyListUrl("https://easylist.to/easylist/easylist.txt");
        QNetworkRequest req(easyListUrl);
        req.setHeader(QNetworkRequest::UserAgentHeader, "ModernQtBrowser/3.0");

        emit statusMessage("Downloading EasyList filter rules...");
        QNetworkReply *reply = m_netManager->get(req);

        connect(reply, &QNetworkReply::finished, this, [this, reply]() {
            reply->deleteLater();
            if (reply->error() != QNetworkReply::NoError) {
                emit statusMessage("EasyList update failed: " + reply->errorString());
                return;
            }

            const QByteArray rawData = reply->readAll();
            if (rawData.isEmpty()) return;

            QFile cacheFile(m_cacheFilePath);
            if (cacheFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                cacheFile.write(rawData);
                cacheFile.close();
            }

            int count = parseEasyListData(rawData);
            emit statusMessage(QString("EasyList updated (%1 active network rules)").arg(count));
        });
    }

    void interceptRequest(QWebEngineUrlRequestInfo &info) override {
        if (!m_enabled.load(std::memory_order_relaxed)) return;

        const QUrl reqUrl = info.requestUrl();
        const QUrl firstParty = info.firstPartyUrl();
        const QString host = reqUrl.host().toLower();
        const QString firstPartyHost = firstParty.host().toLower();
        if (host.isEmpty()) return;

        if (info.resourceType() == QWebEngineUrlRequestInfo::ResourceTypePing) {
            blockRequest(info, host);
            return;
        }

        QReadLocker locker(&m_lock);

        // Bundle E: Allow all requests if the top-level page or target host is whitelisted
        if (matchesDomainSet(firstPartyHost, m_userWhitelist) ||
            matchesDomainSet(host, m_userWhitelist) ||
            matchesDomainSet(host, m_exceptionDomains)) {
            return;
        }

        if (matchesDomainSet(host, m_blockedDomains)) {
            locker.unlock();
            blockRequest(info, host);
            return;
        }

        const bool isThirdParty = !firstPartyHost.isEmpty() &&
                                  !host.endsWith(registeredDomain(firstPartyHost));

        if (isThirdParty && info.resourceType() != QWebEngineUrlRequestInfo::ResourceTypeMainFrame) {
            const QString fullUrl = reqUrl.toString().toLower();
            for (const QString &pattern : m_blockedUrlPatterns) {
                if (fullUrl.contains(pattern)) {
                    locker.unlock();
                    blockRequest(info, host);
                    return;
                }
            }
        }

        locker.unlock();
        info.setHttpHeader("DNT", "1");
        info.setHttpHeader("Sec-GPC", "1");
    }

signals:
    void requestBlocked(const QString &domain, int totalBlocked);
    void statusMessage(const QString &message);

private:
    void initCacheAndSync() {
        QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(appDataDir);
        m_cacheFilePath = appDataDir + "/easylist_cache.txt";

        QFileInfo fi(m_cacheFilePath);
        bool needsDownload = true;

        if (fi.exists() && fi.size() > 0) {
            QFile cacheFile(m_cacheFilePath);
            if (cacheFile.open(QIODevice::ReadOnly)) {
                int count = parseEasyListData(cacheFile.readAll());
                emit statusMessage(QString("Loaded %1 cached ad-block rules").arg(count));
            }
            needsDownload = fi.lastModified().secsTo(QDateTime::currentDateTime()) > 86400;
        }

        if (needsDownload) {
            updateFilterLists();
        }
    }

    int parseEasyListData(const QByteArray &data) {
        QSet<QString> newBlockedDomains = m_blockedDomains;
        QSet<QString> newExceptionDomains;
        QStringList newUrlPatterns = {
            "/pagead/", "/adserver", "/adframe", "/ads.js", "banner_ads"
        };

        QTextStream stream(data);
        while (!stream.atEnd()) {
            QString line = stream.readLine().trimmed();

            if (line.isEmpty() || line.startsWith('!') || line.startsWith('[') ||
                line.contains("##") || line.contains("#@#") || line.contains("#?#")) {
                continue;
            }

            bool isException = false;
            if (line.startsWith("@@")) {
                isException = true;
                line = line.mid(2);
            }

            int dollarIdx = line.indexOf('$');
            if (dollarIdx != -1) {
                QString options = line.mid(dollarIdx + 1).toLower();
                if (options.contains("domain=") || options.contains("elemhide")) {
                    continue;
                }
                line = line.left(dollarIdx);
            }

            if (line.startsWith("||")) {
                QString rule = line.mid(2);
                if (rule.endsWith('^') || rule.endsWith('/')) {
                    rule.chop(1);
                }

                if (!rule.isEmpty() && !rule.contains('/') && !rule.contains('*') && !rule.contains('^')) {
                    if (isException) {
                        newExceptionDomains.insert(rule.toLower());
                    } else {
                        newBlockedDomains.insert(rule.toLower());
                    }
                }
                continue;
            }

            if (!isException && line.startsWith('/') && !line.endsWith('/') &&
                !line.contains('*') && !line.contains('^') && line.length() >= 6) {
                if (newUrlPatterns.size() < 1500) {
                    newUrlPatterns.append(line.toLower());
                }
            }
        }

        int totalRules = newBlockedDomains.size() + newUrlPatterns.size();

        {
            QWriteLocker writeLocker(&m_lock);
            m_blockedDomains.swap(newBlockedDomains);
            m_exceptionDomains.swap(newExceptionDomains);
            m_blockedUrlPatterns.swap(newUrlPatterns);
        }

        return totalRules;
    }

    static bool matchesDomainSet(const QString &host, const QSet<QString> &domainSet) {
        QString current = host;
        while (!current.isEmpty()) {
            if (domainSet.contains(current)) return true;
            int dotIndex = current.indexOf('.');
            if (dotIndex == -1) break;
            current = current.mid(dotIndex + 1);
        }
        return false;
    }

    static QString registeredDomain(const QString &host) {
        QStringList parts = host.split('.');
        return (parts.size() >= 2) ? parts.mid(parts.size() - 2).join('.') : host;
    }

    void blockRequest(QWebEngineUrlRequestInfo &info, const QString &host) {
        info.block(true);
        int total = ++m_blockedCount;
        emit requestBlocked(host, total);
    }

    QNetworkAccessManager *m_netManager;
    QString m_cacheFilePath;
    mutable QReadWriteLock m_lock;

    QSet<QString> m_blockedDomains;
    QSet<QString> m_exceptionDomains;
    QSet<QString> m_userWhitelist;
    QStringList m_blockedUrlPatterns;

    std::atomic<bool> m_enabled{true};
    std::atomic<int> m_blockedCount{0};
};

// ----------------------------------------------------------------------------
// Custom WebView: Enables PDF Viewer, WebRTC Hardening & Split-Pane Focus
// ----------------------------------------------------------------------------
class BrowserTabView : public QWebEngineView {
    Q_OBJECT
public:
    explicit BrowserTabView(QWebEngineProfile *profile, BrowserWindow *mainWin, QWidget *parent = nullptr)
        : QWebEngineView(parent), m_mainWindow(mainWin), m_profile(profile) {
        setPage(new QWebEnginePage(profile, this));
        settings()->setAttribute(QWebEngineSettings::FullScreenSupportEnabled, true);
        settings()->setAttribute(QWebEngineSettings::PluginsEnabled, true);
        settings()->setAttribute(QWebEngineSettings::PdfViewerEnabled, true);
        settings()->setAttribute(QWebEngineSettings::ScreenCaptureEnabled, true);
        settings()->setAttribute(QWebEngineSettings::JavascriptCanOpenWindows, true);
        settings()->setAttribute(QWebEngineSettings::ScrollAnimatorEnabled, true);

        // Bundle F: WebRTC Local IP Leak Protection & DNS Prefetch Hardening
        settings()->setAttribute(QWebEngineSettings::WebRTCPublicInterfacesOnly, true);
        settings()->setAttribute(QWebEngineSettings::DnsPrefetchEnabled, false);
    }

signals:
    void paneFocused(BrowserTabView *view);

protected:
    QWebEngineView *createWindow(QWebEnginePage::WebWindowType type) override;

    void focusInEvent(QFocusEvent *event) override {
        emit paneFocused(this);
        QWebEngineView::focusInEvent(event);
    }

private:
    BrowserWindow *m_mainWindow;
    QWebEngineProfile *m_profile;
};

// ----------------------------------------------------------------------------
// Main Browser Window (v3.0 - All Bundles A through G Integrated)
// ----------------------------------------------------------------------------
class BrowserWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit BrowserWindow(bool incognito = false, QWidget *parent = nullptr)
        : QMainWindow(parent),
          m_isIncognito(incognito),
          m_suggestNetManager(new QNetworkAccessManager(this)),
          m_suggestDebounce(new QTimer(this)) {

        setWindowTitle(m_isIncognito ? "ModernQtBrowser (Private Browsing)" : "ModernQtBrowser");
        setWindowIcon(QIcon::fromTheme("applications-internet", style()->standardIcon(QStyle::SP_DriveNetIcon)));
        resize(1360, 880);

        if (m_isIncognito) {
            m_profile = new QWebEngineProfile(this);
        } else {
            m_profile = new QWebEngineProfile("ModernQtBrowserProfile", this);
            m_profile->setPersistentCookiesPolicy(QWebEngineProfile::AllowPersistentCookies);
        }

        connect(m_profile, &QWebEngineProfile::downloadRequested,
                this, &BrowserWindow::onDownloadRequested);

        m_suggestDebounce->setSingleShot(true);
        m_suggestDebounce->setInterval(180);
        connect(m_suggestDebounce, &QTimer::timeout, this, &BrowserWindow::fetchLiveSearchSuggestions);

        // Initialize AdBlocker before database & profile scripts
        m_adBlocker = new AdBlockInterceptor(this);

        setupUI();
        setupShortcuts();
        initDatabaseAndLoadData();
        initUserscripts();
        configureProfile(m_profile);

        connect(m_adBlocker, &AdBlockInterceptor::requestBlocked, this,
                [this](const QString &domain, int totalBlocked) {
            if (m_adBlockAction && m_adBlocker->isEnabled()) {
                m_adBlockAction->setToolTip(
                    QString("AdBlocker Active (%1 blocked)\nLast blocked: %2\nClick to toggle")
                        .arg(totalBlocked).arg(domain));
            }
        }, Qt::QueuedConnection);

        connect(m_adBlocker, &AdBlockInterceptor::statusMessage, this, [this](const QString &msg) {
            statusBar()->showMessage(msg, 5000);
        });

        if (!restoreSession()) {
            addNewTab(QUrl("about:newtab"));
        }
    }

    BrowserTabView *addNewTab(const QUrl &url = QUrl("about:newtab"), const QString &containerName = QString()) {
        QWebEngineProfile *targetProfile = profileForContainer(containerName);

        // Vertical splitter: top = horizontal pane splitter (for Split-Screen), bottom = DevTools
        QSplitter *tabSplitter = new QSplitter(Qt::Vertical, this);
        tabSplitter->setProperty("container", containerName);

        QSplitter *paneSplitter = new QSplitter(Qt::Horizontal, tabSplitter);
        BrowserTabView *webView = new BrowserTabView(targetProfile, this, paneSplitter);

        webView->page()->setBackgroundColor(palette().color(QPalette::Base));
        paneSplitter->addWidget(webView);
        tabSplitter->addWidget(paneSplitter);

        QString initialLabel = containerName.isEmpty() ? "New Tab" : QString("[%1] New Tab").arg(containerName);
        int index = m_tabs->addTab(tabSplitter,
                                   themeIcon("text-html", QStyle::SP_FileIcon),
                                   initialLabel);
        m_tabs->setCurrentIndex(index);
        m_lastFocusedView = webView;

        wireWebViewSignals(webView, tabSplitter);

        if (url.isEmpty() || url.toString() == "about:newtab") {
            loadSpeedDial(webView);
        } else if (url.isValid()) {
            webView->setUrl(url);
        }
        return webView;
    }

protected:
    void changeEvent(QEvent *event) override {
        if (event->type() == QEvent::PaletteChange || event->type() == QEvent::ApplicationPaletteChange) {
            configureProfile(m_profile);
            for (auto *prof : m_containerProfiles) configureProfile(prof);
            for (int i = 0; i < m_tabs->count(); ++i) {
                if (auto *v = webViewAt(i)) {
                    if (v->url().toString() == "about:newtab") loadSpeedDial(v);
                }
            }
        }
        QMainWindow::changeEvent(event);
    }

    void closeEvent(QCloseEvent *event) override {
        saveSession();
        QMainWindow::closeEvent(event);
    }

private slots:
    // Bundle E: Omnibox Navigation with Custom Search Bangs (!yt, !gh, !w, !g, !aw, !so, !r)
    void navigateToInput() {
        QString input = m_urlBar->text().trimmed();
        if (input.isEmpty()) return;

        if (input.contains(" | ")) {
            input = input.section(" | ", -1).trimmed();
            m_urlBar->setText(input);
        }

        if (input == "about:newtab") {
            if (auto *v = currentWebView()) loadSpeedDial(v);
            return;
        }

        // Check Search Engine Bangs
        static const QMap<QString, QString> searchBangs = {
            {"!yt ", "https://www.youtube.com/results?search_query="},
            {"!gh ", "https://github.com/search?q="},
            {"!w ",  "https://en.wikipedia.org/w/index.php?search="},
            {"!g ",  "https://www.google.com/search?q="},
            {"!aw ", "https://wiki.archlinux.org/index.php?search="},
            {"!so ", "https://stackoverflow.com/search?q="},
            {"!r ",  "https://www.reddit.com/search/?q="}
        };

        for (auto it = searchBangs.constBegin(); it != searchBangs.constEnd(); ++it) {
            if (input.startsWith(it.key(), Qt::CaseInsensitive)) {
                QString term = input.mid(it.key().length()).trimmed();
                if (!term.isEmpty()) {
                    if (auto *view = currentWebView()) {
                        view->setUrl(QUrl(it.value() + QUrl::toPercentEncoding(term)));
                    }
                    return;
                }
            }
        }

        QUrl targetUrl;
        QRegularExpression domainRegex(R"(^(https?://|file://|localhost|\d{1,3}(\.\d{1,3}){3}|([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}))");
        if (domainRegex.match(input).hasMatch() && !input.contains(' ')) {
            targetUrl = QUrl::fromUserInput(input);
        } else {
            targetUrl = QUrl("https://duckduckgo.com/?q=" + QUrl::toPercentEncoding(input));
        }

        if (auto *view = currentWebView()) {
            view->setUrl(targetUrl);
        }
    }

    // Bundle D: Toggle Split-Screen Side-by-Side View inside Active Tab (Ctrl+Shift+S)
    void toggleSplitScreen() {
        QSplitter *tabSplitter = currentSplitter();
        if (!tabSplitter) return;
        QSplitter *paneSplitter = qobject_cast<QSplitter *>(tabSplitter->widget(0));
        if (!paneSplitter) return;

        if (paneSplitter->count() > 1) {
            QWidget *secondPane = paneSplitter->widget(1);
            if (m_lastFocusedView == secondPane) {
                m_lastFocusedView = qobject_cast<BrowserTabView *>(paneSplitter->widget(0));
            }
            secondPane->deleteLater();
            statusBar()->showMessage("Closed Split-Screen pane", 2500);
        } else {
            QString containerName = tabSplitter->property("container").toString();
            QWebEngineProfile *prof = profileForContainer(containerName);
            BrowserTabView *secondView = new BrowserTabView(prof, this, paneSplitter);
            secondView->page()->setBackgroundColor(palette().color(QPalette::Base));
            paneSplitter->addWidget(secondView);
            paneSplitter->setSizes({650, 650});
            wireWebViewSignals(secondView, tabSplitter);
            loadSpeedDial(secondView);
            m_lastFocusedView = secondView;
            m_urlBar->clear();
            m_urlBar->setFocus();
            statusBar()->showMessage("Split-Screen active — click either pane to focus its address in the Omnibox", 4000);
        }
    }

    // Bundle D: Spotlight / KRunner Style Command Palette (Ctrl+K)
    void openCommandPalette() {
        QDialog dlg(this, Qt::Popup | Qt::FramelessWindowHint);
        dlg.resize(620, 400);

        QVBoxLayout *layout = new QVBoxLayout(&dlg);
        layout->setContentsMargins(10, 10, 10, 10);

        QLineEdit *searchBox = new QLineEdit(&dlg);
        searchBox->setPlaceholderText("Type a command, open tab title, or URL (Press Esc to close)...");
        searchBox->setClearButtonEnabled(true);

        QListWidget *resultsList = new QListWidget(&dlg);
        resultsList->setAlternatingRowColors(true);

        layout->addWidget(searchBox);
        layout->addWidget(resultsList);

        auto addEntry = [&](const QIcon &icon, const QString &label, const QString &type, const QVariant &payload) {
            auto *item = new QListWidgetItem(icon, label, resultsList);
            item->setData(Qt::UserRole, type);
            item->setData(Qt::UserRole + 1, payload);
        };

        // 1. Add Open Tabs
        const QIcon tabIcon = themeIcon("tab-new", QStyle::SP_FileIcon);
        for (int i = 0; i < m_tabs->count(); ++i) {
            if (auto *v = webViewAt(i)) {
                addEntry(v->icon().isNull() ? tabIcon : v->icon(),
                         QString("[Switch Tab #%1] %2 — %3").arg(i + 1).arg(v->title(), v->url().toString()),
                         "TAB", i);
            }
        }

        // 2. Add Browser Commands
        const QIcon cmdIcon = themeIcon("tools-wizard", QStyle::SP_ComputerIcon);
        addEntry(cmdIcon, "[Command] Toggle Split-Screen Side-by-Side View (Ctrl+Shift+S)", "CMD", "split");
        addEntry(cmdIcon, "[Command] Toggle Distraction-Free Reader Mode (Ctrl+Alt+R)", "CMD", "reader");
        addEntry(cmdIcon, "[Command] Capture Viewport Screenshot to Clipboard & Pictures (Ctrl+Shift+Y)", "CMD", "screenshot");
        addEntry(cmdIcon, "[Command] Toggle Picture-in-Picture Video Popout (Ctrl+Shift+V)", "CMD", "pip");
        addEntry(cmdIcon, "[Command] Whitelist / Unwhitelist Current Site in AdBlocker", "CMD", "whitelist");
        addEntry(cmdIcon, "[Command] Clear Cookies & Site Data for Active Profile", "CMD", "cleardata");
        addEntry(cmdIcon, "[Command] Hibernate All Background Tabs (Free RAM)", "CMD", "hibernate_all");
        addEntry(cmdIcon, "[Command] New Container Tab: Personal", "CMD", "container_Personal");
        addEntry(cmdIcon, "[Command] New Container Tab: Work", "CMD", "container_Work");
        addEntry(cmdIcon, "[Command] New Container Tab: Banking", "CMD", "container_Banking");
        addEntry(cmdIcon, "[Command] Export Current Page to PDF (Ctrl+P)", "CMD", "pdf");
        addEntry(cmdIcon, "[Command] Toggle Developer Tools (F12)", "CMD", "devtools");

        // 3. Add Top Bookmarks
        const QIcon bmIcon = themeIcon("bookmarks", QStyle::SP_DialogYesButton);
        for (int i = 0; i < m_bookmarksList->count(); ++i) {
            const QString raw = m_bookmarksList->item(i)->text();
            addEntry(bmIcon, "[Bookmark] " + raw, "URL", raw.section(" | ", -1).trimmed());
        }

        if (resultsList->count() > 0) resultsList->setCurrentRow(0);

        connect(searchBox, &QLineEdit::textChanged, &dlg, [resultsList](const QString &filter) {
            int firstVisible = -1;
            for (int i = 0; i < resultsList->count(); ++i) {
                QListWidgetItem *it = resultsList->item(i);
                bool match = it->text().contains(filter, Qt::CaseInsensitive);
                it->setHidden(!match);
                if (match && firstVisible == -1) firstVisible = i;
            }
            if (firstVisible != -1) resultsList->setCurrentRow(firstVisible);
        });

        auto executeItem = [&](QListWidgetItem *item) {
            if (!item) return;
            const QString type = item->data(Qt::UserRole).toString();
            const QVariant payload = item->data(Qt::UserRole + 1);
            dlg.accept();

            if (type == "TAB") {
                m_tabs->setCurrentIndex(payload.toInt());
            } else if (type == "URL") {
                addNewTab(QUrl(payload.toString()));
            } else if (type == "CMD") {
                const QString cmd = payload.toString();
                if (cmd == "split") toggleSplitScreen();
                else if (cmd == "reader") toggleReaderMode();
                else if (cmd == "screenshot") takeScreenshot();
                else if (cmd == "pip") togglePictureInPicture();
                else if (cmd == "whitelist") toggleCurrentSiteWhitelist();
                else if (cmd == "cleardata") clearSiteDataAndCookies();
                else if (cmd == "pdf") savePageAsPdf();
                else if (cmd == "devtools") toggleDevTools();
                else if (cmd == "hibernate_all") {
                    for (int i = 0; i < m_tabs->count(); ++i) {
                        if (i != m_tabs->currentIndex()) hibernateTab(i);
                    }
                } else if (cmd.startsWith("container_")) {
                    addNewTab(QUrl("about:newtab"), cmd.section('_', 1));
                }
            }
        };

        connect(searchBox, &QLineEdit::returnPressed, &dlg, [&]() {
            executeItem(resultsList->currentItem());
        });
        connect(resultsList, &QListWidget::itemActivated, &dlg, executeItem);

        // Center dialog over browser window
        dlg.move(geometry().center() - dlg.rect().center());
        searchBox->setFocus();
        dlg.exec();
    }

    // Bundle D: Viewport Screenshot to Clipboard & ~/Pictures/ModernQtBrowser (Ctrl+Shift+Y)
    void takeScreenshot() {
        BrowserTabView *view = currentWebView();
        if (!view) return;

        QPixmap pixmap = view->grab();
        if (pixmap.isNull()) return;

        QApplication::clipboard()->setPixmap(pixmap);

        QString picDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/ModernQtBrowser";
        QDir().mkpath(picDir);
        QString filePath = picDir + "/screenshot_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".png";
        pixmap.save(filePath, "PNG");

        statusBar()->showMessage("Screenshot copied to clipboard and saved to: " + filePath, 5000);
    }

    // Bundle G: Picture-in-Picture (PiP) Floating Video Popout (Ctrl+Shift+V)
    void togglePictureInPicture() {
        BrowserTabView *view = currentWebView();
        if (!view) return;

        view->page()->runJavaScript(R"(
            (function() {
                if (document.pictureInPictureElement) {
                    document.exitPictureInPicture();
                    return "EXITED";
                }
                const videos = Array.from(document.querySelectorAll('video'));
                if (videos.length === 0) return "NO_VIDEO";
                const playing = videos.find(v => !v.paused) || videos[0];
                playing.requestPictureInPicture();
                return "ENTERED";
            })();
        )", [this](const QVariant &res) {
            const QString state = res.toString();
            if (state == "NO_VIDEO") {
                statusBar()->showMessage("No HTML5 video found on the current page", 3000);
            } else if (state == "ENTERED") {
                statusBar()->showMessage("Entered Picture-in-Picture mode", 3000);
            } else {
                statusBar()->showMessage("Exited Picture-in-Picture mode", 2500);
            }
        });
    }

    // Bundle E: Toggle Per-Site AdBlocker Whitelist
    void toggleCurrentSiteWhitelist() {
        BrowserTabView *view = currentWebView();
        if (!view || view->url().host().isEmpty()) return;

        const QString host = view->url().host().toLower();
        bool whitelisted = m_adBlocker->toggleWhitelistDomain(host);

        if (m_db.isOpen()) {
            QSqlQuery q(m_db);
            if (whitelisted) {
                q.prepare("INSERT OR IGNORE INTO whitelist (domain) VALUES (:d)");
            } else {
                q.prepare("DELETE FROM whitelist WHERE domain = :d");
            }
            q.bindValue(":d", host);
            q.exec();
        }

        statusBar()->showMessage(whitelisted
            ? QString("Whitelisted %1 in AdBlocker (reloading...)").arg(host)
            : QString("Removed %1 from AdBlocker whitelist (reloading...)").arg(host), 3500);
        view->reload();
    }

    // Bundle F: Clear Cookies & HTTP Cache
    void clearSiteDataAndCookies() {
        BrowserTabView *view = currentWebView();
        QWebEngineProfile *prof = view ? view->page()->profile() : m_profile;
        prof->cookieStore()->deleteAllCookies();
        prof->clearHttpCache();
        statusBar()->showMessage("Cleared all cookies and HTTP cache for active profile", 3500);
    }

    void closeTab(int index) {
        if (index < 0 || index >= m_tabs->count()) return;

        if (isTabPinned(index)) {
            statusBar()->showMessage("Tab is pinned. Unpin it first to close.", 2500);
            return;
        }

        if (auto *view = webViewAt(index)) {
            const QUrl closedUrl = view->url();
            if (closedUrl.isValid() && closedUrl.toString() != "about:newtab" && !closedUrl.isEmpty()) {
                m_closedTabs.push(closedUrl);
            }
        }

        if (m_tabs->count() <= 1) {
            close();
            return;
        }
        QWidget *widget = m_tabs->widget(index);
        if (m_lastFocusedView && widget->isAncestorOf(m_lastFocusedView)) {
            m_lastFocusedView = nullptr;
        }
        m_tabs->removeTab(index);
        widget->deleteLater();
    }

    void restoreClosedTab() {
        if (m_closedTabs.isEmpty()) {
            statusBar()->showMessage("No recently closed tabs to reopen", 2500);
            return;
        }
        QUrl url = m_closedTabs.pop();
        addNewTab(url);
        statusBar()->showMessage("Reopened closed tab: " + url.toString(), 2500);
    }

    void hibernateTab(int index) {
        BrowserTabView *webView = webViewAt(index);
        if (!webView) return;

        if (m_tabs->currentIndex() == index) {
            if (m_tabs->count() <= 1) {
                statusBar()->showMessage("Open another tab before hibernating the active tab.", 3000);
                return;
            }
            int nextIdx = (index == 0) ? 1 : index - 1;
            m_tabs->setCurrentIndex(nextIdx);
        }

        webView->page()->setLifecycleState(QWebEnginePage::LifecycleState::Discarded);
        updateTabIcon(m_tabs->widget(index), webView);
        statusBar()->showMessage("Tab hibernated — memory freed until clicked", 3000);
    }

    void toggleReaderMode() {
        BrowserTabView *view = currentWebView();
        if (!view || view->url().toString() == "about:newtab") return;

        const bool isDark = palette().color(QPalette::Window).lightness() < 128;
        const QString bgHex = palette().color(QPalette::Base).name();
        const QString fgHex = palette().color(QPalette::Text).name();
        const QString accentHex = palette().color(QPalette::Highlight).name();

        QString js = QString(R"(
            (function() {
                if (window.__modernQtReaderActive) {
                    location.reload();
                    return "EXIT";
                }
                const root = document.querySelector('article, main, [role="main"], .post-content, .article-body') || document.body;
                const title = document.title;
                const clone = root.cloneNode(true);
                clone.querySelectorAll('script, style, nav, header, footer, aside, iframe, form, .sidebar, .ad, .comments').forEach(e => e.remove());

                document.head.innerHTML = `<meta charset="utf-8"><title>${title} — Reader Mode</title>
                    <style>
                        body {
                            background: %1; color: %2;
                            font-family: 'Noto Serif', Georgia, serif;
                            max-width: 740px; margin: 48px auto; padding: 0 24px;
                            line-height: 1.75; font-size: 19px;
                        }
                        h1, h2, h3 { font-family: 'Noto Sans', system-ui, sans-serif; line-height: 1.3; }
                        h1 { border-bottom: 2px solid %3; padding-bottom: 12px; }
                        a { color: %3; }
                        img { max-width: 100%; height: auto; border-radius: 6px; margin: 16px 0; }
                        pre, code { background: %4; padding: 4px 8px; border-radius: 4px; overflow-x: auto; }
                    </style>`;
                document.body.innerHTML = `<h1>${title}</h1>` + clone.innerHTML;
                window.__modernQtReaderActive = true;
                return "ENTER";
            })();
        )").arg(bgHex, fgHex, accentHex, isDark ? "#2a2a3c" : "#eef0f4");

        view->page()->runJavaScript(js, [this](const QVariant &res) {
            if (res.toString() == "ENTER") {
                statusBar()->showMessage("Reader Mode enabled (click Reader icon again to exit)", 3000);
            } else {
                statusBar()->showMessage("Exited Reader Mode", 2000);
            }
        });
    }

    void savePageAsPdf() {
        BrowserTabView *view = currentWebView();
        if (!view) return;

        QString defaultName = view->title().simplified().replace(QRegularExpression("[^a-zA-Z0-9_-]"), "_");
        if (defaultName.isEmpty()) defaultName = "page";
        QString filePath = QFileDialog::getSaveFileName(this, "Export Page to PDF",
                                                        defaultName + ".pdf", "PDF Documents (*.pdf)");
        if (filePath.isEmpty()) return;

        statusBar()->showMessage("Generating PDF...", 3000);
        view->page()->printToPdf(filePath);
        connect(view->page(), &QWebEnginePage::pdfPrintingFinished, this,
                [this](const QString &path, bool success) {
            if (success) {
                statusBar()->showMessage("Saved PDF to: " + path, 5000);
            } else {
                statusBar()->showMessage("Failed to save PDF", 4000);
            }
        }, Qt::SingleShotConnection);
    }

    void fetchLiveSearchSuggestions() {
        const QString query = m_urlBar->text().trimmed();
        if (query.length() < 2 || query.contains("://") || query.contains(" | ") || query.startsWith('!')) {
            return;
        }

        QUrl apiUrl("https://ac.duckduckgo.com/ac/");
        QUrlQuery urlQuery;
        urlQuery.addQueryItem("q", query);
        urlQuery.addQueryItem("type", "list");
        apiUrl.setQuery(urlQuery);

        QNetworkRequest req(apiUrl);
        req.setHeader(QNetworkRequest::UserAgentHeader, "ModernQtBrowser/3.0");
        QNetworkReply *reply = m_suggestNetManager->get(req);

        connect(reply, &QNetworkReply::finished, this, [this, reply, query]() {
            reply->deleteLater();
            if (reply->error() != QNetworkReply::NoError) return;
            if (m_urlBar->text().trimmed() != query) return;

            QStringList livePhrases;
            QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            if (doc.isArray() && doc.array().size() >= 2 && doc.array()[1].isArray()) {
                for (const QJsonValue &val : doc.array()[1].toArray()) {
                    const QString phrase = val.toString().trimmed();
                    if (!phrase.isEmpty()) livePhrases << phrase;
                    if (livePhrases.size() >= 5) break;
                }
            } else if (doc.isArray()) {
                for (const QJsonValue &val : doc.array()) {
                    if (val.isObject()) {
                        const QString phrase = val.toObject().value("phrase").toString().trimmed();
                        if (!phrase.isEmpty()) livePhrases << phrase;
                        if (livePhrases.size() >= 5) break;
                    }
                }
            }

            if (!livePhrases.isEmpty()) {
                rebuildOmniboxCompletions(livePhrases);
                if (m_urlBar->hasFocus()) {
                    m_urlCompleter->complete();
                }
            }
        });
    }

    void showTabContextMenu(const QPoint &pos) {
        QTabBar *tabBar = m_tabs->tabBar();
        int index = tabBar->tabAt(pos);
        if (index == -1) return;

        BrowserTabView *webView = webViewAt(index);
        if (!webView) return;

        QMenu menu(this);

        menu.addAction(themeIcon("view-refresh", QStyle::SP_BrowserReload),
                       "Reload Tab", this, [webView]() {
            webView->reload();
        });

        menu.addAction(themeIcon("tab-duplicate", QStyle::SP_FileDialogNewFolder),
                       "Duplicate Tab", this, [this, index, webView]() {
            QString container = m_tabs->widget(index)->property("container").toString();
            addNewTab(webView->url(), container);
            m_tabs->tabBar()->moveTab(m_tabs->count() - 1, index + 1);
        });

        menu.addAction(themeIcon("view-split-left-right", QStyle::SP_FileDialogDetailedView),
                       "Toggle Split-Screen in Tab\tCtrl+Shift+S", this, [this, index]() {
            m_tabs->setCurrentIndex(index);
            toggleSplitScreen();
        });

        menu.addSeparator();

        const bool pinned = isTabPinned(index);
        menu.addAction(themeIcon("window-pin", QStyle::SP_DialogApplyButton),
                       pinned ? "Unpin Tab" : "Pin Tab", this, [this, index]() {
            togglePinTab(index);
        });

        const bool muted = webView->page()->isAudioMuted();
        menu.addAction(
            themeIcon(muted ? "audio-volume-high" : "audio-volume-muted",
                      muted ? QStyle::SP_MediaVolume : QStyle::SP_MediaVolumeMuted),
            muted ? "Unmute Tab" : "Mute Tab", this, [this, index, webView, muted]() {
                webView->page()->setAudioMuted(!muted);
                updateTabIcon(m_tabs->widget(index), webView);
            });

        const bool isDiscarded = webView->page()->lifecycleState() == QWebEnginePage::LifecycleState::Discarded;
        QAction *hibernateAct = menu.addAction(
            themeIcon("system-suspend", QStyle::SP_ComputerIcon),
            isDiscarded ? "Tab Hibernated (Memory Saved)" : "Hibernate Tab (Free Memory)",
            this, [this, index]() { hibernateTab(index); });
        hibernateAct->setEnabled(!isDiscarded && m_tabs->count() > 1);

        menu.addSeparator();

        QAction *reopenAct = menu.addAction(
            themeIcon("edit-undo", QStyle::SP_ArrowBack),
            "Reopen Closed Tab\tCtrl+Shift+T", this, [this]() { restoreClosedTab(); });
        reopenAct->setEnabled(!m_closedTabs.isEmpty());

        menu.addSeparator();

        QWidget *clickedWidget = m_tabs->widget(index);
        QAction *closeOthersAct = menu.addAction(
            themeIcon("tab-close-other", QStyle::SP_DialogCloseButton),
            "Close Other Tabs", this, [this, clickedWidget]() {
                for (int i = m_tabs->count() - 1; i >= 0; --i) {
                    if (m_tabs->widget(i) != clickedWidget && !isTabPinned(i)) {
                        closeTab(i);
                    }
                }
            });
        closeOthersAct->setEnabled(m_tabs->count() > 1);

        QAction *closeRightAct = menu.addAction(
            themeIcon("tab-close", QStyle::SP_DialogCloseButton),
            "Close Tabs to the Right", this, [this, index]() {
                for (int i = m_tabs->count() - 1; i > index; --i) {
                    if (!isTabPinned(i)) {
                        closeTab(i);
                    }
                }
            });
        closeRightAct->setEnabled(index < m_tabs->count() - 1);

        menu.addAction(
            themeIcon("window-close", QStyle::SP_DialogCloseButton),
            "Close Tab\tCtrl+W", this, [this, index]() {
                if (isTabPinned(index)) togglePinTab(index);
                closeTab(index);
            });

        menu.exec(tabBar->mapToGlobal(pos));
    }

    void toggleDevTools() {
        QSplitter *splitter = currentSplitter();
        BrowserTabView *view = currentWebView();
        if (!splitter || !view) return;

        if (splitter->count() > 1) {
            QWidget *devView = splitter->widget(1);
            view->page()->setDevToolsPage(nullptr);
            devView->deleteLater();
        } else {
            QWebEngineView *devView = new QWebEngineView(splitter);
            view->page()->setDevToolsPage(devView->page());
            splitter->addWidget(devView);
            splitter->setSizes({550, 300});
        }
    }

    void bookmarkCurrentPage() {
        BrowserTabView *view = currentWebView();
        if (!view || view->url().toString() == "about:newtab") return;

        const QString title = view->title().isEmpty() ? view->url().host() : view->title();
        const QString urlStr = view->url().toString();
        const QString entry = QString("%1 | %2").arg(title, urlStr);

        if (m_bookmarksList->findItems(entry, Qt::MatchExactly).isEmpty()) {
            m_bookmarksList->addItem(entry);
            if (!m_isIncognito && m_db.isOpen()) {
                QSqlQuery q(m_db);
                q.prepare("INSERT OR REPLACE INTO bookmarks (url, title, added_at) VALUES (:u, :t, :d)");
                q.bindValue(":u", urlStr);
                q.bindValue(":t", title);
                q.bindValue(":d", QDateTime::currentDateTime().toString(Qt::ISODate));
                q.exec();
            }
            rebuildOmniboxCompletions();
            rebuildBookmarksBar();
            statusBar()->showMessage("Bookmark saved to SQLite database & Bookmarks Bar", 2500);
        }
    }

    void onDownloadRequested(QWebEngineDownloadRequest *download) {
        QString defaultPath = download->downloadFileName();
        QString savePath = QFileDialog::getSaveFileName(this, "Save File", defaultPath);
        if (savePath.isEmpty()) {
            download->cancel();
            return;
        }

        QFileInfo fi(savePath);
        download->setDownloadDirectory(fi.absolutePath());
        download->setDownloadFileName(fi.fileName());
        download->accept();

        m_SideDock->show();
        QWidget *itemWidget = new QWidget();
        QHBoxLayout *layout = new QHBoxLayout(itemWidget);
        layout->setContentsMargins(4, 4, 4, 4);
        QLabel *nameLabel = new QLabel(fi.fileName());
        QProgressBar *bar = new QProgressBar();
        bar->setRange(0, 100);
        layout->addWidget(nameLabel);
        layout->addWidget(bar);

        QListWidgetItem *item = new QListWidgetItem(m_downloadsList);
        item->setSizeHint(itemWidget->sizeHint());
        m_downloadsList->addItem(item);
        m_downloadsList->setItemWidget(item, itemWidget);

        connect(download, &QWebEngineDownloadRequest::receivedBytesChanged, this, [download, bar]() {
            qint64 total = download->totalBytes();
            if (total > 0) {
                bar->setValue(static_cast<int>((download->receivedBytes() * 100) / total));
            }
        });

        connect(download, &QWebEngineDownloadRequest::isFinishedChanged, this, [this, download, bar, fi]() {
            if (download->isFinished()) {
                bar->setValue(100);
                statusBar()->showMessage("Download complete: " + fi.fileName(), 4000);
            }
        });
    }

private:
    BrowserTabView *currentWebView() const {
        return webViewAt(m_tabs->currentIndex());
    }

    BrowserTabView *webViewAt(int index) const {
        if (auto *vSplit = qobject_cast<QSplitter *>(m_tabs->widget(index))) {
            if (auto *hSplit = qobject_cast<QSplitter *>(vSplit->widget(0))) {
                if (m_lastFocusedView && hSplit->indexOf(m_lastFocusedView) != -1) {
                    return m_lastFocusedView;
                }
                return qobject_cast<BrowserTabView *>(hSplit->widget(0));
            }
        }
        return nullptr;
    }

    QSplitter *currentSplitter() const {
        return qobject_cast<QSplitter *>(m_tabs->currentWidget());
    }

    bool isTabPinned(int index) const {
        QWidget *w = m_tabs->widget(index);
        return w && w->property("pinned").toBool();
    }

    // Bundle F: Retrieve or Create Isolated Container QWebEngineProfile
    QWebEngineProfile *profileForContainer(const QString &containerName) {
        if (containerName.isEmpty() || m_isIncognito) return m_profile;
        if (m_containerProfiles.contains(containerName)) {
            return m_containerProfiles.value(containerName);
        }
        auto *prof = new QWebEngineProfile("ModernQtContainer_" + containerName, this);
        prof->setPersistentCookiesPolicy(QWebEngineProfile::AllowPersistentCookies);
        connect(prof, &QWebEngineProfile::downloadRequested, this, &BrowserWindow::onDownloadRequested);
        configureProfile(prof);
        m_containerProfiles.insert(containerName, prof);
        return prof;
    }

    // Attach AdBlocker, Color Scheme, Cosmetic Filter, Fingerprint Hardening, Mouse Gestures & Userscripts
    void configureProfile(QWebEngineProfile *prof) {
        if (!prof) return;
        prof->setUrlRequestInterceptor(m_adBlocker);

        const bool isDarkTheme = palette().color(QPalette::Window).lightness() < 128;

        // 1. KDE System Color Scheme Sync
        QWebEngineScript darkSchemeScript;
        darkSchemeScript.setName("SystemColorSchemeSync");
        darkSchemeScript.setInjectionPoint(QWebEngineScript::DocumentCreation);
        darkSchemeScript.setWorldId(QWebEngineScript::ApplicationWorld);
        darkSchemeScript.setSourceCode(QString(R"(
            (function() {
                let meta = document.querySelector('meta[name="color-scheme"]');
                if (!meta && document.head) {
                    meta = document.createElement('meta');
                    meta.name = 'color-scheme';
                    meta.content = '%1';
                    document.head.appendChild(meta);
                }
            })();
        )").arg(isDarkTheme ? "dark light" : "light dark"));

        // 2. Cosmetic Ad Container Filter
        QWebEngineScript cosmeticScript;
        cosmeticScript.setName("CosmeticAdBlock");
        cosmeticScript.setInjectionPoint(QWebEngineScript::DocumentReady);
        cosmeticScript.setWorldId(QWebEngineScript::ApplicationWorld);
        cosmeticScript.setRunsOnSubFrames(true);
        cosmeticScript.setSourceCode(R"(
            (function() {
                const style = document.createElement('style');
                style.textContent = `
                    .ad-banner, .ad-container, .adsbox, .sponsored-content,
                    [id^="google_ads_iframe"], [id^="div-gpt-ad"],
                    iframe[src*="doubleclick.net"], iframe[src*="googlesyndication.com"] {
                        display: none !important;
                    }
                `;
                if (document.head) document.head.appendChild(style);
            })();
        )");

        // 3. Bundle F & G: Canvas Anti-Fingerprinting + Right-Click Drag Mouse Gestures
        QWebEngineScript privacyAndGesturesScript;
        privacyAndGesturesScript.setName("PrivacyAndMouseGestures");
        privacyAndGesturesScript.setInjectionPoint(QWebEngineScript::DocumentCreation);
        privacyAndGesturesScript.setWorldId(QWebEngineScript::MainWorld);
        privacyAndGesturesScript.setSourceCode(R"(
            (function() {
                // Global Privacy Control Signal
                try { Object.defineProperty(navigator, 'globalPrivacyControl', { value: true, configurable: false }); } catch(e) {}

                // Subtle Canvas Fingerprint Noise
                const origToDataURL = HTMLCanvasElement.prototype.toDataURL;
                HTMLCanvasElement.prototype.toDataURL = function() {
                    const ctx = this.getContext('2d');
                    if (ctx && this.width > 0 && this.height > 0) {
                        try {
                            const img = ctx.getImageData(0, 0, 1, 1);
                            img.data[0] = (img.data[0] + 1) % 256;
                            ctx.putImageData(img, 0, 0);
                        } catch(e) {}
                    }
                    return origToDataURL.apply(this, arguments);
                };

                // Mouse Gestures: Right-click + drag Left (Back), Right (Forward), Up (Scroll Top)
                let gx = 0, gy = 0, tracking = false, suppressMenu = false;
                window.addEventListener('mousedown', e => {
                    if (e.button === 2) { gx = e.screenX; gy = e.screenY; tracking = true; }
                }, true);
                window.addEventListener('mouseup', e => {
                    if (e.button === 2 && tracking) {
                        tracking = false;
                        const dx = e.screenX - gx, dy = e.screenY - gy;
                        if (Math.hypot(dx, dy) > 110) {
                            suppressMenu = true;
                            if (Math.abs(dx) > Math.abs(dy)) {
                                if (dx < 0) history.back();
                                else history.forward();
                            } else if (dy < 0) {
                                window.scrollTo({ top: 0, behavior: 'smooth' });
                            }
                        }
                    }
                }, true);
                window.addEventListener('contextmenu', e => {
                    if (suppressMenu) { e.preventDefault(); suppressMenu = false; }
                }, true);
            })();
        )");

        auto replaceScript = [prof](const QWebEngineScript &s) {
            for (const auto &old : prof->scripts()->find(s.name())) {
                prof->scripts()->remove(old);
            }
            prof->scripts()->insert(s);
        };

        replaceScript(darkSchemeScript);
        replaceScript(cosmeticScript);
        replaceScript(privacyAndGesturesScript);
        for (const auto &uScript : m_loadedUserscripts) {
            replaceScript(uScript);
        }
    }

    // Bundle E: Load Greasemonkey / Tampermonkey *.user.js Scripts
    void initUserscripts() {
        m_userscriptsDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/userscripts";
        QDir dir(m_userscriptsDir);
        if (!dir.exists()) dir.mkpath(".");

        // Create a sample starter userscript if directory is empty
        if (dir.entryList({"*.user.js"}, QDir::Files).isEmpty()) {
            QFile sample(m_userscriptsDir + "/smooth_focus_ring.user.js");
            if (sample.open(QIODevice::WriteOnly | QIODevice::Text)) {
                sample.write(R"(// ==UserScript==
// @name        Smooth Focus & Scrollbars
// @match       *://*/*
// @run-at      document-end
// ==/UserScript==
(function() {
    const s = document.createElement('style');
    s.textContent = 'html { scroll-behavior: smooth; }';
    if (document.head) document.head.appendChild(s);
})();
)");
                sample.close();
            }
        }

        m_loadedUserscripts.clear();
        if (m_userscriptsList) m_userscriptsList->clear();

        for (const QFileInfo &fi : dir.entryInfoList({"*.user.js"}, QDir::Files)) {
            QFile f(fi.absoluteFilePath());
            if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) continue;
            const QString code = QString::fromUtf8(f.readAll());

            QWebEngineScript script;
            script.setName("Userscript_" + fi.fileName());
            script.setInjectionPoint(code.contains("@run-at      document-start")
                                     ? QWebEngineScript::DocumentCreation
                                     : QWebEngineScript::DocumentReady);
            script.setWorldId(QWebEngineScript::MainWorld);
            script.setRunsOnSubFrames(false);
            script.setSourceCode(code);
            m_loadedUserscripts.append(script);

            if (m_userscriptsList) {
                m_userscriptsList->addItem(fi.fileName());
            }
        }
    }

    void wireWebViewSignals(BrowserTabView *webView, QSplitter *tabSplitter) {
        connect(webView, &BrowserTabView::paneFocused, this, [this](BrowserTabView *focused) {
            m_lastFocusedView = focused;
            if (focused->url().toString() == "about:newtab") {
                m_urlBar->clear();
            } else {
                m_urlBar->setText(focused->url().toString());
            }
            updateSecurityIcon(focused->url());
            updateNavigationActions();
        });

        connect(webView, &QWebEngineView::titleChanged, this, [this, tabSplitter, webView](const QString &title) {
            int idx = m_tabs->indexOf(tabSplitter);
            if (idx != -1) {
                const QString container = tabSplitter->property("container").toString();
                const QString prefix = container.isEmpty() ? "" : QString("[%1] ").arg(container);
                if (isTabPinned(idx)) {
                    m_tabs->setTabText(idx, QString());
                    m_tabs->setTabToolTip(idx, prefix + title + " (Pinned)");
                } else {
                    QString full = prefix + (title.isEmpty() ? "New Tab" : title);
                    QString shortTitle = full.left(26) + (full.length() > 26 ? "..." : "");
                    m_tabs->setTabText(idx, shortTitle);
                    m_tabs->setTabToolTip(idx, full);
                }
            }
            if (currentWebView() == webView) {
                setWindowTitle(title + (m_isIncognito ? " [Private]" : " — ModernQtBrowser"));
            }
        });

        connect(webView, &QWebEngineView::iconChanged, this, [this, tabSplitter, webView](const QIcon &) {
            updateTabIcon(tabSplitter, webView);
        });

        connect(webView->page(), &QWebEnginePage::recentlyAudibleChanged, this, [this, tabSplitter, webView](bool) {
            updateTabIcon(tabSplitter, webView);
        });

        connect(webView->page(), &QWebEnginePage::audioMutedChanged, this, [this, tabSplitter, webView](bool) {
            updateTabIcon(tabSplitter, webView);
        });

        connect(webView->page(), &QWebEnginePage::lifecycleStateChanged, this, [this, tabSplitter, webView]() {
            updateTabIcon(tabSplitter, webView);
        });

        connect(webView, &QWebEngineView::urlChanged, this, [this, webView](const QUrl &qurl) {
            if (currentWebView() == webView) {
                if (qurl.toString() == "about:newtab") {
                    m_urlBar->clear();
                } else {
                    m_urlBar->setText(qurl.toString());
                }
                updateSecurityIcon(qurl);
                updateNavigationActions();
            }
        });

        connect(webView, &QWebEngineView::loadProgress, this, [this, webView](int progress) {
            if (currentWebView() == webView) {
                m_progressBar->setVisible(progress > 0 && progress < 100);
                m_progressBar->setValue(progress);
            }
        });

        connect(webView, &QWebEngineView::loadFinished, this, [this, webView](bool ok) {
            if (!ok) return;
            if (!m_isIncognito) {
                recordHistory(webView->title(), webView->url());
            }
            if (currentWebView() == webView) {
                updateNavigationActions();
            }
        });

        connect(webView->page(), &QWebEnginePage::linkHovered, this, [this](const QString &linkUrl) {
            statusBar()->showMessage(linkUrl, 3000);
        });

        connect(webView->page(), &QWebEnginePage::fullScreenRequested, this, [this](QWebEngineFullScreenRequest req) {
            req.accept();
            if (req.toggleOn()) {
                m_navBar->hide();
                m_bookmarksBar->hide();
                m_tabs->tabBar()->hide();
                statusBar()->hide();
                showFullScreen();
            } else {
                m_navBar->show();
                if (m_bookmarksBarVisible) m_bookmarksBar->show();
                m_tabs->tabBar()->show();
                statusBar()->show();
                showNormal();
            }
        });

#if QT_VERSION >= QT_VERSION_CHECK(6, 8, 0)
        connect(webView->page(), &QWebEnginePage::permissionRequested, this, [this](QWebEnginePermission perm) {
            QString featureName = "a device feature";
            switch (perm.permissionType()) {
                case QWebEnginePermission::PermissionType::MediaAudioCapture: featureName = "your Microphone"; break;
                case QWebEnginePermission::PermissionType::MediaVideoCapture: featureName = "your Camera"; break;
                case QWebEnginePermission::PermissionType::MediaAudioVideoCapture: featureName = "your Camera and Microphone"; break;
                case QWebEnginePermission::PermissionType::DesktopVideoCapture:
                case QWebEnginePermission::PermissionType::DesktopAudioVideoCapture: featureName = "Screen Sharing"; break;
                case QWebEnginePermission::PermissionType::Geolocation: featureName = "your Location"; break;
                case QWebEnginePermission::PermissionType::Notifications: featureName = "Desktop Notifications"; break;
                case QWebEnginePermission::PermissionType::ClipboardReadWrite: featureName = "your Clipboard"; break;
                default: break;
            }
            auto reply = QMessageBox::question(
                this, "Website Permission Request",
                QString("<b>%1</b> wants to access <b>%2</b>.<br><br>Do you want to allow this?")
                    .arg(perm.origin().host(), featureName),
                QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
            if (reply == QMessageBox::Yes) perm.grant();
            else perm.deny();
        });
#else
        connect(webView->page(), &QWebEnginePage::featurePermissionRequested,
                this, [this, webView](const QUrl &securityOrigin, QWebEnginePage::Feature feature) {
            QString featureName = "a device feature";
            switch (feature) {
                case QWebEnginePage::MediaAudioCapture: featureName = "your Microphone"; break;
                case QWebEnginePage::MediaVideoCapture: featureName = "your Camera"; break;
                case QWebEnginePage::MediaAudioVideoCapture: featureName = "your Camera and Microphone"; break;
                case QWebEnginePage::DesktopVideoCapture:
                case QWebEnginePage::DesktopAudioVideoCapture: featureName = "Screen Sharing"; break;
                case QWebEnginePage::Geolocation: featureName = "your Location"; break;
                case QWebEnginePage::Notifications: featureName = "Desktop Notifications"; break;
                default: break;
            }
            auto reply = QMessageBox::question(
                this, "Website Permission Request",
                QString("<b>%1</b> wants to access <b>%2</b>.<br><br>Do you want to allow this?")
                    .arg(securityOrigin.host(), featureName),
                QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
            webView->page()->setFeaturePermission(
                securityOrigin, feature,
                reply == QMessageBox::Yes ? QWebEnginePage::PermissionGrantedByUser
                                          : QWebEnginePage::PermissionDeniedByUser);
        });
#endif
    }

    void updateTabIcon(QWidget *tabContainer, BrowserTabView *webView) {
        int idx = m_tabs->indexOf(tabContainer);
        if (idx == -1 || !webView) return;

        if (webView->page()->lifecycleState() == QWebEnginePage::LifecycleState::Discarded) {
            m_tabs->setTabIcon(idx, themeIcon("system-suspend", QStyle::SP_ComputerIcon));
        } else if (webView->page()->isAudioMuted()) {
            m_tabs->setTabIcon(idx, themeIcon("audio-volume-muted", QStyle::SP_MediaVolumeMuted));
        } else if (webView->page()->recentlyAudible()) {
            m_tabs->setTabIcon(idx, themeIcon("audio-volume-high", QStyle::SP_MediaVolume));
        } else if (!webView->icon().isNull()) {
            m_tabs->setTabIcon(idx, webView->icon());
        } else {
            m_tabs->setTabIcon(idx, themeIcon("text-html", QStyle::SP_FileIcon));
        }
    }

    void togglePinTab(int index) {
        QWidget *tabContainer = m_tabs->widget(index);
        BrowserTabView *webView = webViewAt(index);
        if (!tabContainer || !webView) return;

        const bool pin = !isTabPinned(index);
        tabContainer->setProperty("pinned", pin);

        QTabBar *tabBar = m_tabs->tabBar();
        auto closeSide = static_cast<QTabBar::ButtonPosition>(
            style()->styleHint(QStyle::SH_TabBar_CloseButtonPosition, nullptr, tabBar));

        if (pin) {
            int targetIdx = 0;
            for (int i = 0; i < m_tabs->count(); ++i) {
                if (i != index && isTabPinned(i)) ++targetIdx;
            }
            tabBar->moveTab(index, targetIdx);

            if (QWidget *closeBtn = tabBar->tabButton(targetIdx, closeSide)) {
                closeBtn->hide();
            }
            m_tabs->setTabText(targetIdx, QString());
            m_tabs->setTabToolTip(targetIdx, webView->title() + " (Pinned)");
        } else {
            int targetIdx = 0;
            for (int i = 0; i < m_tabs->count(); ++i) {
                if (isTabPinned(i)) ++targetIdx;
            }
            if (index < targetIdx) --targetIdx;
            tabBar->moveTab(index, targetIdx);

            if (QWidget *closeBtn = tabBar->tabButton(targetIdx, closeSide)) {
                closeBtn->show();
            }
            QString title = webView->title();
            QString shortTitle = title.left(24) + (title.length() > 24 ? "..." : "");
            m_tabs->setTabText(targetIdx, shortTitle.isEmpty() ? "New Tab" : shortTitle);
            m_tabs->setTabToolTip(targetIdx, title);
        }
    }

    void loadSpeedDial(BrowserTabView *webView) {
        if (!webView) return;

        const QString winBg = palette().color(QPalette::Window).name();
        const QString cardBg = palette().color(QPalette::Base).name();
        const QString textFg = palette().color(QPalette::Text).name();
        const QString accent = palette().color(QPalette::Highlight).name();

        QString cardsHtml;
        int count = 0;
        for (int i = 0; i < m_bookmarksList->count() && count < 8; ++i, ++count) {
            const QString raw = m_bookmarksList->item(i)->text();
            const QString title = raw.section(" | ", 0, -2).trimmed().toHtmlEscaped();
            const QString url = raw.section(" | ", -1).trimmed().toHtmlEscaped();
            cardsHtml += QString(R"(
                <a class="card" href="%1">
                    <div class="badge">%2</div>
                    <div class="title">%3</div>
                    <div class="url">%1</div>
                </a>
            )").arg(url, title.left(1).toUpper(), title);
        }

        struct QuickSite { const char *name; const char *url; };
        const QuickSite defaults[] = {
            {"Wikipedia", "https://www.wikipedia.org"},
            {"KDE Community", "https://kde.org"},
            {"GitHub", "https://github.com"},
            {"DuckDuckGo", "https://duckduckgo.com"},
            {"Qt Documentation", "https://doc.qt.io"},
            {"Hacker News", "https://news.ycombinator.com"}
        };
        for (const auto &site : defaults) {
            if (count >= 8) break;
            cardsHtml += QString(R"(
                <a class="card" href="%1">
                    <div class="badge">%2</div>
                    <div class="title">%3</div>
                    <div class="url">%1</div>
                </a>
            )").arg(site.url, QString(site.name).left(1), site.name);
            ++count;
        }

        QString html = QString(R"(
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>New Tab</title>
                <style>
                    * { box-sizing: border-box; }
                    body {
                        background-color: %1; color: %3;
                        font-family: 'Noto Sans', system-ui, sans-serif;
                        margin: 0; display: flex; flex-direction: column;
                        align-items: center; justify-content: center; min-height: 92vh;
                    }
                    h1 { font-size: 28px; font-weight: 600; margin-bottom: 8px; letter-spacing: -0.5px; }
                    .subtitle { font-size: 13px; opacity: 0.65; margin-bottom: 24px; }
                    form { width: 100%; max-width: 580px; margin-bottom: 36px; }
                    input[type="text"] {
                        width: 100%; padding: 14px 20px; border-radius: 10px;
                        border: 2px solid rgba(128,128,128,0.25);
                        background: %2; color: %3; font-size: 16px; outline: none;
                        transition: border-color 0.15s;
                    }
                    input[type="text"]:focus { border-color: %4; }
                    .grid {
                        display: grid; grid-template-columns: repeat(auto-fill, minmax(155px, 1fr));
                        gap: 16px; width: 100%; max-width: 720px; padding: 0 20px;
                    }
                    .card {
                        background: %2; color: %3; text-decoration: none;
                        padding: 18px 14px; border-radius: 10px;
                        border: 1px solid rgba(128,128,128,0.18);
                        display: flex; flex-direction: column; align-items: center;
                        transition: transform 0.12s, border-color 0.12s;
                    }
                    .card:hover { transform: translateY(-3px); border-color: %4; }
                    .badge {
                        width: 42px; height: 42px; border-radius: 50%;
                        background: %4; color: #fff; font-weight: 700; font-size: 18px;
                        display: flex; align-items: center; justify-content: center;
                        margin-bottom: 10px;
                    }
                    .title { font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 130px; }
                    .url { font-size: 11px; opacity: 0.6; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 130px; margin-top: 4px; }
                </style>
            </head>
            <body>
                <h1>ModernQtBrowser</h1>
                <div class="subtitle">Press Ctrl+K for Command Palette | Ctrl+Shift+S for Split-Screen | Bangs: !yt !gh !w !g</div>
                <form action="https://duckduckgo.com/" method="GET">
                    <input type="text" name="q" placeholder="Search DuckDuckGo or type a URL..." autofocus />
                </form>
                <div class="grid">%5</div>
            </body>
            </html>
        )").arg(winBg, cardBg, textFg, accent, cardsHtml);

        webView->setHtml(html, QUrl("about:newtab"));
    }

    void rebuildBookmarksBar() {
        if (!m_bookmarksBar) return;
        m_bookmarksBar->clear();

        const QIcon bmIcon = themeIcon("bookmarks", QStyle::SP_DialogYesButton);
        if (m_bookmarksList->count() == 0) {
            QAction *emptyAct = m_bookmarksBar->addAction(bmIcon, "Press Ctrl+D on any page to add bookmarks here");
            emptyAct->setEnabled(false);
            return;
        }

        for (int i = 0; i < qMin(m_bookmarksList->count(), 18); ++i) {
            const QString raw = m_bookmarksList->item(i)->text();
            const QString title = raw.section(" | ", 0, -2).trimmed();
            const QString urlStr = raw.section(" | ", -1).trimmed();
            QString shortLabel = title.left(20) + (title.length() > 20 ? "..." : "");

            QAction *act = m_bookmarksBar->addAction(bmIcon, shortLabel, this, [this, urlStr]() {
                if (auto *v = currentWebView()) v->setUrl(QUrl(urlStr));
            });
            act->setToolTip(title + "\n" + urlStr);
        }
    }

    // Bundle G: Rebuild Omnibox QCompleter Ranked by SQLite Frecency (Visit Count + Recency)
    void rebuildOmniboxCompletions(const QStringList &liveSearchPhrases = {}) {
        if (!m_completerModel) return;
        m_completerModel->clear();

        QSet<QString> seenUrls;

        // 1. Live Search Suggestions
        const QIcon searchIcon = themeIcon("edit-find", QStyle::SP_FileDialogContentsView);
        for (const QString &phrase : liveSearchPhrases) {
            const QString searchUrl = "https://duckduckgo.com/?q=" + QUrl::toPercentEncoding(phrase);
            auto *item = new QStandardItem(searchIcon, QString("%1 — Search DuckDuckGo | %2").arg(phrase, searchUrl));
            item->setData(searchUrl, Qt::UserRole);
            m_completerModel->appendRow(item);
        }

        // 2. Bookmarks
        const QIcon bookmarkIcon = themeIcon("bookmarks", QStyle::SP_DialogYesButton);
        for (int i = 0; i < m_bookmarksList->count(); ++i) {
            const QString raw = m_bookmarksList->item(i)->text();
            const QString url = raw.section(" | ", -1).trimmed();
            const QString title = raw.section(" | ", 0, -2).trimmed();

            if (url.isEmpty() || seenUrls.contains(url)) continue;
            seenUrls.insert(url);

            auto *item = new QStandardItem(bookmarkIcon, QString("%1 | %2").arg(title, url));
            item->setData(url, Qt::UserRole);
            m_completerModel->appendRow(item);
        }

        // 3. Frecency-Ordered History from SQLite
        const QIcon historyIcon = themeIcon("view-history", QStyle::SP_FileDialogInfoView);
        if (m_db.isOpen()) {
            QSqlQuery q("SELECT title, url, visit_count FROM history ORDER BY visit_count DESC, last_visited DESC LIMIT 200", m_db);
            while (q.next()) {
                const QString title = q.value(0).toString();
                const QString url = q.value(1).toString();
                const int visits = q.value(2).toInt();
                if (url.isEmpty() || seenUrls.contains(url)) continue;
                seenUrls.insert(url);

                auto *item = new QStandardItem(historyIcon, QString("%1 (%2x) | %3").arg(title).arg(visits).arg(url));
                item->setData(url, Qt::UserRole);
                m_completerModel->appendRow(item);
            }
        }
    }

    // Bundle G: Initialize SQLite Database & Load History, Bookmarks, and Whitelist
    void initDatabaseAndLoadData() {
        QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(appDataDir);

        const QString connName = QString("ModernQtDB_%1").arg(reinterpret_cast<quintptr>(this));
        m_db = QSqlDatabase::addDatabase("QSQLITE", connName);
        m_db.setDatabaseName(appDataDir + "/browser.db");

        if (!m_db.open()) return;

        QSqlQuery q(m_db);
        q.exec("CREATE TABLE IF NOT EXISTS history ("
               "url TEXT PRIMARY KEY, title TEXT, visit_count INTEGER DEFAULT 1, last_visited TEXT)");
        q.exec("CREATE TABLE IF NOT EXISTS bookmarks ("
               "url TEXT PRIMARY KEY, title TEXT, added_at TEXT)");
        q.exec("CREATE TABLE IF NOT EXISTS whitelist ("
               "domain TEXT PRIMARY KEY)");

        // Load History ordered by recency into Library list
        QSqlQuery hq("SELECT title, url, visit_count, last_visited FROM history ORDER BY last_visited DESC LIMIT 500", m_db);
        while (hq.next()) {
            m_historyList->addItem(QString("[%1] (%2x) %3 | %4")
                .arg(hq.value(3).toString(), hq.value(2).toString(), hq.value(0).toString(), hq.value(1).toString()));
        }

        // Load Bookmarks
        QSqlQuery bq("SELECT title, url FROM bookmarks ORDER BY added_at DESC", m_db);
        while (bq.next()) {
            m_bookmarksList->addItem(QString("%1 | %2").arg(bq.value(0).toString(), bq.value(1).toString()));
        }

        // Load Whitelisted Domains
        QSet<QString> whitelistSet;
        QSqlQuery wq("SELECT domain FROM whitelist", m_db);
        while (wq.next()) {
            whitelistSet.insert(wq.value(0).toString());
        }
        m_adBlocker->setUserWhitelist(whitelistSet);

        rebuildOmniboxCompletions();
        rebuildBookmarksBar();
    }

    void recordHistory(const QString &title, const QUrl &url) {
        if (url.toString().isEmpty() || url.scheme() == "about") return;
        const QString urlStr = url.toString();
        const QString cleanTitle = title.isEmpty() ? url.host() : title;
        const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm");

        int visits = 1;
        if (m_db.isOpen()) {
            QSqlQuery checkQ(m_db);
            checkQ.prepare("SELECT visit_count FROM history WHERE url = :u");
            checkQ.bindValue(":u", urlStr);
            if (checkQ.exec() && checkQ.next()) {
                visits = checkQ.value(0).toInt() + 1;
            }

            QSqlQuery insQ(m_db);
            insQ.prepare("INSERT OR REPLACE INTO history (url, title, visit_count, last_visited) "
                         "VALUES (:u, :t, :c, :d)");
            insQ.bindValue(":u", urlStr);
            insQ.bindValue(":t", cleanTitle);
            insQ.bindValue(":c", visits);
            insQ.bindValue(":d", timestamp);
            insQ.exec();
        }

        QString entry = QString("[%1] (%2x) %3 | %4").arg(timestamp).arg(visits).arg(cleanTitle, urlStr);
        m_historyList->insertItem(0, entry);
        rebuildOmniboxCompletions();
    }

    void saveSession() {
        if (m_isIncognito) return;
        QSettings settings("ModernQt", "BrowserData");
        QStringList urls, containers;
        QList<QVariant> pinnedFlags;
        for (int i = 0; i < m_tabs->count(); ++i) {
            if (auto *v = webViewAt(i)) {
                QString u = v->url().toString();
                urls << (u.isEmpty() ? "about:newtab" : u);
                containers << m_tabs->widget(i)->property("container").toString();
                pinnedFlags << isTabPinned(i);
            }
        }
        settings.setValue("session_urls", urls);
        settings.setValue("session_containers", containers);
        settings.setValue("session_pinned", pinnedFlags);
        settings.setValue("session_active_index", m_tabs->currentIndex());
        settings.setValue("bookmarks_bar_visible", m_bookmarksBarVisible);
    }

    bool restoreSession() {
        if (m_isIncognito) return false;
        QSettings settings("ModernQt", "BrowserData");
        m_bookmarksBarVisible = settings.value("bookmarks_bar_visible", true).toBool();
        m_bookmarksBar->setVisible(m_bookmarksBarVisible);

        QStringList urls = settings.value("session_urls").toStringList();
        QStringList containers = settings.value("session_containers").toStringList();
        QList<QVariant> pinnedFlags = settings.value("session_pinned").toList();
        if (urls.isEmpty()) return false;

        for (int i = 0; i < urls.size(); ++i) {
            QString cont = (i < containers.size()) ? containers[i] : QString();
            addNewTab(QUrl(urls[i]), cont);
            if (i < pinnedFlags.size() && pinnedFlags[i].toBool()) {
                togglePinTab(m_tabs->count() - 1);
            }
        }
        int activeIdx = settings.value("session_active_index", 0).toInt();
        if (activeIdx >= 0 && activeIdx < m_tabs->count()) {
            m_tabs->setCurrentIndex(activeIdx);
        }
        return true;
    }

    QIcon themeIcon(const QString &breezeName, QStyle::StandardPixmap fallback) const {
        return QIcon::fromTheme(breezeName, style()->standardIcon(fallback));
    }

    void updateSecurityIcon(const QUrl &url) {
        if (!m_securityAction) return;
        if (url.scheme() == "https") {
            m_securityAction->setIcon(themeIcon("security-high", QStyle::SP_VistaShield));
            m_securityAction->setToolTip("Secure HTTPS Connection");
        } else if (url.toString() == "about:newtab") {
            m_securityAction->setIcon(themeIcon("go-home", QStyle::SP_DirHomeIcon));
            m_securityAction->setToolTip("Speed Dial New Tab Page");
        } else {
            m_securityAction->setIcon(themeIcon("channel-insecure-symbolic", QStyle::SP_MessageBoxWarning));
            m_securityAction->setToolTip("Unencrypted Connection");
        }
    }

    void updateNavigationActions() {
        if (auto *view = currentWebView()) {
            m_backAction->setEnabled(view->history()->canGoBack());
            m_forwardAction->setEnabled(view->history()->canGoForward());
        }
    }

    void setupUI() {
        setUnifiedTitleAndToolBarOnMac(true);

        // 1. Primary Navigation Toolbar
        m_navBar = addToolBar("Navigation ToolBar");
        m_navBar->setMovable(false);
        m_navBar->setFloatable(false);
        m_navBar->setContextMenuPolicy(Qt::PreventContextMenu);
        m_navBar->setToolButtonStyle(Qt::ToolButtonIconOnly);

        m_backAction = m_navBar->addAction(
            themeIcon("go-previous", QStyle::SP_ArrowBack), "Back", this, [this]() {
                if (auto *v = currentWebView()) v->back();
            });
        m_forwardAction = m_navBar->addAction(
            themeIcon("go-next", QStyle::SP_ArrowForward), "Forward", this, [this]() {
                if (auto *v = currentWebView()) v->forward();
            });
        m_reloadAction = m_navBar->addAction(
            themeIcon("view-refresh", QStyle::SP_BrowserReload), "Reload", this, [this]() {
                if (auto *v = currentWebView()) v->reload();
            });
        m_navBar->addAction(
            themeIcon("go-home", QStyle::SP_DirHomeIcon), "Speed Dial Home", this, [this]() {
                if (auto *v = currentWebView()) loadSpeedDial(v);
            });

        // 2. Omnibox with Bangs (!yt, !gh, !w), Live Search, Reader Mode, PiP, Bookmark & AdBlocker
        m_urlBar = new QLineEdit(this);
        m_urlBar->setClearButtonEnabled(true);
        m_urlBar->setPlaceholderText("Search DuckDuckGo, enter URL, or use bangs (!yt, !gh, !w, !g)...");
        connect(m_urlBar, &QLineEdit::returnPressed, this, &BrowserWindow::navigateToInput);
        connect(m_urlBar, &QLineEdit::textEdited, this, [this](const QString &) {
            m_suggestDebounce->start();
        });

        m_completerModel = new QStandardItemModel(this);
        m_urlCompleter = new QCompleter(m_completerModel, this);
        m_urlCompleter->setCaseSensitivity(Qt::CaseInsensitive);
        m_urlCompleter->setFilterMode(Qt::MatchContains);
        m_urlCompleter->setCompletionMode(QCompleter::PopupCompletion);
        m_urlCompleter->setMaxVisibleItems(12);
        m_urlBar->setCompleter(m_urlCompleter);

        connect(m_urlCompleter, QOverload<const QModelIndex &>::of(&QCompleter::activated),
                this, [this](const QModelIndex &index) {
            const QString targetUrl = index.data(Qt::UserRole).toString();
            if (!targetUrl.isEmpty()) {
                m_urlBar->setText(targetUrl);
                navigateToInput();
            }
        }, Qt::QueuedConnection);

        m_securityAction = m_urlBar->addAction(
            themeIcon("security-high", QStyle::SP_VistaShield), QLineEdit::LeadingPosition);

        QAction *pipInlineAction = m_urlBar->addAction(
            themeIcon("view-fullscreen", QStyle::SP_MediaPlay), QLineEdit::TrailingPosition);
        pipInlineAction->setToolTip("Toggle Picture-in-Picture Video Popout (Ctrl+Shift+V)");
        connect(pipInlineAction, &QAction::triggered, this, &BrowserWindow::togglePictureInPicture);

        QAction *readerInlineAction = m_urlBar->addAction(
            themeIcon("view-readermode", QStyle::SP_FileDialogContentsView), QLineEdit::TrailingPosition);
        readerInlineAction->setToolTip("Toggle Distraction-Free Reader Mode (Ctrl+Alt+R)");
        connect(readerInlineAction, &QAction::triggered, this, &BrowserWindow::toggleReaderMode);

        QAction *bookmarkInlineAction = m_urlBar->addAction(
            themeIcon("bookmarks", QStyle::SP_DialogYesButton), QLineEdit::TrailingPosition);
        bookmarkInlineAction->setToolTip("Bookmark this page (Ctrl+D)");
        connect(bookmarkInlineAction, &QAction::triggered, this, &BrowserWindow::bookmarkCurrentPage);

        m_adBlockAction = m_urlBar->addAction(
            themeIcon("security-high", QStyle::SP_VistaShield), QLineEdit::TrailingPosition);
        m_adBlockAction->setToolTip("Toggle Ad & Tracker Blocker");
        connect(m_adBlockAction, &QAction::triggered, this, [this]() {
            bool newState = !m_adBlocker->isEnabled();
            m_adBlocker->setEnabled(newState);
            if (newState) {
                m_adBlockAction->setIcon(themeIcon("security-high", QStyle::SP_VistaShield));
                statusBar()->showMessage("Ad & Tracker Blocker enabled", 2500);
            } else {
                m_adBlockAction->setIcon(themeIcon("security-low", QStyle::SP_MessageBoxWarning));
                statusBar()->showMessage("Ad & Tracker Blocker paused", 2500);
            }
            if (auto *v = currentWebView()) v->reload();
        });

        m_navBar->addWidget(m_urlBar);

        // 3. Right-side Toolbar Buttons (Split-Screen, Command Palette, Screenshot, Sidebar, Menu)
        m_navBar->addAction(
            themeIcon("view-split-left-right", QStyle::SP_FileDialogDetailedView),
            "Toggle Split-Screen View (Ctrl+Shift+S)", this, &BrowserWindow::toggleSplitScreen);

        m_navBar->addAction(
            themeIcon("system-search", QStyle::SP_FileDialogContentsView),
            "Command Palette & Quick Tab Switcher (Ctrl+K)", this, &BrowserWindow::openCommandPalette);

        m_navBar->addAction(
            themeIcon("camera-photo", QStyle::SP_DialogSaveButton),
            "Take Screenshot to Clipboard & Pictures (Ctrl+Shift+Y)", this, &BrowserWindow::takeScreenshot);

        m_navBar->addAction(
            themeIcon("view-sidetree", QStyle::SP_FileDialogInfoView),
            "Toggle Library Sidebar (Ctrl+H)", this, [this]() {
                m_SideDock->setVisible(!m_SideDock->isVisible());
            });

        QToolButton *menuButton = new QToolButton(this);
        menuButton->setIcon(themeIcon("application-menu", QStyle::SP_TitleBarMenuButton));
        menuButton->setToolTip("Menu");
        menuButton->setPopupMode(QToolButton::InstantPopup);

        QMenu *appMenu = new QMenu(menuButton);
        appMenu->addAction(themeIcon("tab-new", QStyle::SP_FileDialogNewFolder), "New Tab\tCtrl+T", this, [this]() { addNewTab(); });

        // Bundle F: Multi-Account Container Submenu
        QMenu *containerMenu = appMenu->addMenu(themeIcon("folder", QStyle::SP_FileDialogNewFolder), "New Container Tab");
        for (const QString &cName : {"Personal", "Work", "Banking", "Shopping"}) {
            containerMenu->addAction(cName, this, [this, cName]() {
                addNewTab(QUrl("about:newtab"), cName);
            });
        }

        appMenu->addAction(themeIcon("edit-undo", QStyle::SP_ArrowBack), "Reopen Closed Tab\tCtrl+Shift+T", this, &BrowserWindow::restoreClosedTab);
        appMenu->addAction(themeIcon("view-private", QStyle::SP_DialogResetButton), "New Private Window", this, []() {
            (new BrowserWindow(true))->show();
        });
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("system-search", QStyle::SP_FileDialogContentsView), "Command Palette...\tCtrl+K", this, &BrowserWindow::openCommandPalette);
        appMenu->addAction(themeIcon("view-split-left-right", QStyle::SP_FileDialogDetailedView), "Split-Screen View\tCtrl+Shift+S", this, &BrowserWindow::toggleSplitScreen);
        appMenu->addAction(themeIcon("camera-photo", QStyle::SP_DialogSaveButton), "Capture Screenshot\tCtrl+Shift+Y", this, &BrowserWindow::takeScreenshot);
        appMenu->addAction(themeIcon("view-fullscreen", QStyle::SP_MediaPlay), "Picture-in-Picture Video\tCtrl+Shift+V", this, &BrowserWindow::togglePictureInPicture);
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("bookmarks", QStyle::SP_DialogYesButton), "Toggle Bookmarks Bar\tCtrl+Shift+B", this, [this]() {
            m_bookmarksBarVisible = !m_bookmarksBarVisible;
            m_bookmarksBar->setVisible(m_bookmarksBarVisible);
        });
        appMenu->addAction(themeIcon("view-readermode", QStyle::SP_FileDialogContentsView), "Toggle Reader Mode\tCtrl+Alt+R", this, &BrowserWindow::toggleReaderMode);
        appMenu->addAction(themeIcon("document-print", QStyle::SP_DialogSaveButton), "Save Page as PDF...\tCtrl+P", this, &BrowserWindow::savePageAsPdf);
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("security-high", QStyle::SP_VistaShield), "Whitelist / Unwhitelist Current Site in AdBlocker", this, &BrowserWindow::toggleCurrentSiteWhitelist);
        appMenu->addAction(themeIcon("edit-clear-history", QStyle::SP_TrashIcon), "Clear Cookies & Site Data", this, &BrowserWindow::clearSiteDataAndCookies);
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("edit-find", QStyle::SP_FileDialogContentsView), "Find in Page...\tCtrl+F", this, [this]() {
            m_findBar->show();
            m_findInput->setFocus();
            m_findInput->selectAll();
        });
        appMenu->addAction(themeIcon("tools-wizard", QStyle::SP_ComputerIcon), "Developer Tools\tF12", this, &BrowserWindow::toggleDevTools);
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("application-exit", QStyle::SP_DialogCloseButton), "Quit\tCtrl+Q", qApp, &QApplication::closeAllWindows);
        menuButton->setMenu(appMenu);
        m_navBar->addWidget(menuButton);

        // 4. Secondary Bookmarks Toolbar
        addToolBarBreak(Qt::TopToolBarArea);
        m_bookmarksBar = addToolBar("Bookmarks Bar");
        m_bookmarksBar->setMovable(false);
        m_bookmarksBar->setFloatable(false);
        m_bookmarksBar->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
        m_bookmarksBar->setIconSize(QSize(16, 16));

        // 5. Bottom Find-in-Page Toolbar
        m_findBar = new QToolBar("Find", this);
        m_findBar->setMovable(false);
        addToolBar(Qt::BottomToolBarArea, m_findBar);
        m_findBar->hide();
        m_findInput = new QLineEdit(this);
        m_findInput->setClearButtonEnabled(true);
        m_findInput->setPlaceholderText("Find in page...");
        connect(m_findInput, &QLineEdit::textChanged, this, [this](const QString &text) {
            if (auto *v = currentWebView()) v->findText(text);
        });
        m_findBar->addWidget(new QLabel(" Find: "));
        m_findBar->addWidget(m_findInput);
        m_findBar->addAction(themeIcon("window-close", QStyle::SP_DialogCloseButton), "Close", this, [this]() {
            m_findBar->hide();
            if (auto *v = currentWebView()) v->findText("");
        });

        // 6. Central Native QTabWidget with Corner New-Tab + Container Selector
        m_tabs = new QTabWidget(this);
        m_tabs->setDocumentMode(true);
        m_tabs->setTabsClosable(true);
        m_tabs->setMovable(true);
        m_tabs->setElideMode(Qt::ElideRight);

        m_tabs->tabBar()->setContextMenuPolicy(Qt::CustomContextMenu);
        connect(m_tabs->tabBar(), &QTabBar::customContextMenuRequested,
                this, &BrowserWindow::showTabContextMenu);

        QToolButton *newTabButton = new QToolButton(m_tabs);
        newTabButton->setIcon(themeIcon("tab-new", QStyle::SP_FileDialogNewFolder));
        newTabButton->setToolTip("Left-click: New Tab (Ctrl+T) | Hold/Arrow: New Container Tab");
        newTabButton->setPopupMode(QToolButton::MenuButtonPopup);
        newTabButton->setAutoRaise(true);
        newTabButton->setMenu(containerMenu);
        connect(newTabButton, &QToolButton::clicked, this, [this]() { addNewTab(); });
        m_tabs->setCornerWidget(newTabButton, Qt::TopRightCorner);

        connect(m_tabs, &QTabWidget::tabCloseRequested, this, &BrowserWindow::closeTab);
        connect(m_tabs, &QTabWidget::currentChanged, this, [this](int index) {
            m_lastFocusedView = nullptr;
            if (auto *v = webViewAt(index)) {
                if (v->page()->lifecycleState() == QWebEnginePage::LifecycleState::Discarded) {
                    v->page()->setLifecycleState(QWebEnginePage::LifecycleState::Active);
                    updateTabIcon(m_tabs->widget(index), v);
                }
                if (v->url().toString() == "about:newtab") {
                    m_urlBar->clear();
                } else {
                    m_urlBar->setText(v->url().toString());
                }
                updateSecurityIcon(v->url());
                updateNavigationActions();
            }
        });
        setCentralWidget(m_tabs);

        // 7. Native Status Bar
        m_progressBar = new QProgressBar(this);
        m_progressBar->setMaximumWidth(140);
        m_progressBar->setMaximumHeight(12);
        m_progressBar->setTextVisible(false);
        statusBar()->addPermanentWidget(m_progressBar);

        // 8. Native QDockWidget for History, Bookmarks, Downloads & Userscripts
        m_SideDock = new QDockWidget("Library & Extensions", this);
        QTabWidget *dockTabs = new QTabWidget(m_SideDock);
        dockTabs->setDocumentMode(true);

        // History Tab
        QWidget *historyPage = new QWidget();
        QVBoxLayout *histLayout = new QVBoxLayout(historyPage);
        m_historySearch = new QLineEdit();
        m_historySearch->setClearButtonEnabled(true);
        m_historySearch->setPlaceholderText("Filter SQLite history...");
        m_historyList = new QListWidget();
        m_historyList->setAlternatingRowColors(true);
        QPushButton *clearHistBtn = new QPushButton(themeIcon("edit-clear-history", QStyle::SP_TrashIcon), "Clear All History");
        histLayout->addWidget(m_historySearch);
        histLayout->addWidget(m_historyList);
        histLayout->addWidget(clearHistBtn);

        connect(m_historySearch, &QLineEdit::textChanged, this, [this](const QString &filter) {
            for (int i = 0; i < m_historyList->count(); ++i) {
                QListWidgetItem *item = m_historyList->item(i);
                item->setHidden(!item->text().contains(filter, Qt::CaseInsensitive));
            }
        });
        connect(m_historyList, &QListWidget::itemDoubleClicked, this, [this](QListWidgetItem *item) {
            QString urlStr = item->text().section(" | ", -1);
            addNewTab(QUrl(urlStr));
        });
        connect(clearHistBtn, &QPushButton::clicked, this, [this]() {
            m_historyList->clear();
            if (m_db.isOpen()) {
                QSqlQuery q(m_db);
                q.exec("DELETE FROM history");
            }
            rebuildOmniboxCompletions();
        });

        // Bookmarks Tab
        m_bookmarksList = new QListWidget();
        m_bookmarksList->setAlternatingRowColors(true);
        connect(m_bookmarksList, &QListWidget::itemDoubleClicked, this, [this](QListWidgetItem *item) {
            QString urlStr = item->text().section(" | ", -1);
            addNewTab(QUrl(urlStr));
        });

        // Downloads Tab
        m_downloadsList = new QListWidget();
        m_downloadsList->setAlternatingRowColors(true);

        // Bundle E: Userscripts Tab
        QWidget *userscriptsPage = new QWidget();
        QVBoxLayout *usLayout = new QVBoxLayout(userscriptsPage);
        m_userscriptsList = new QListWidget();
        m_userscriptsList->setAlternatingRowColors(true);
        QPushButton *openUsDirBtn = new QPushButton(themeIcon("folder", QStyle::SP_FileDialogNewFolder), "Open Userscripts Folder");
        QPushButton *reloadUsBtn = new QPushButton(themeIcon("view-refresh", QStyle::SP_BrowserReload), "Reload *.user.js Scripts");
        usLayout->addWidget(new QLabel("Active *.user.js scripts:"));
        usLayout->addWidget(m_userscriptsList);
        usLayout->addWidget(openUsDirBtn);
        usLayout->addWidget(reloadUsBtn);

        connect(openUsDirBtn, &QPushButton::clicked, this, [this]() {
            QDesktopServices::openUrl(QUrl::fromLocalFile(m_userscriptsDir));
        });
        connect(reloadUsBtn, &QPushButton::clicked, this, [this]() {
            initUserscripts();
            configureProfile(m_profile);
            for (auto *prof : m_containerProfiles) configureProfile(prof);
            statusBar()->showMessage(QString("Reloaded %1 userscripts").arg(m_loadedUserscripts.size()), 3000);
        });

        dockTabs->addTab(historyPage, themeIcon("view-history", QStyle::SP_FileDialogInfoView), "History");
        dockTabs->addTab(m_bookmarksList, themeIcon("bookmarks", QStyle::SP_DialogYesButton), "Bookmarks");
        dockTabs->addTab(m_downloadsList, themeIcon("folder-download", QStyle::SP_ArrowDown), "Downloads");
        dockTabs->addTab(userscriptsPage, themeIcon("tools-wizard", QStyle::SP_ComputerIcon), "Userscripts");

        m_SideDock->setWidget(dockTabs);
        addDockWidget(Qt::LeftDockWidgetArea, m_SideDock);
        m_SideDock->hide();
    }

    void setupShortcuts() {
        new QShortcut(QKeySequence("Ctrl+T"), this, [this]() { addNewTab(); });
        new QShortcut(QKeySequence("Ctrl+Shift+T"), this, [this]() { restoreClosedTab(); });
        new QShortcut(QKeySequence("Ctrl+W"), this, [this]() { closeTab(m_tabs->currentIndex()); });
        new QShortcut(QKeySequence("Ctrl+L"), this, [this]() { m_urlBar->setFocus(); m_urlBar->selectAll(); });
        new QShortcut(QKeySequence("Ctrl+K"), this, [this]() { openCommandPalette(); });
        new QShortcut(QKeySequence("Ctrl+Shift+P"), this, [this]() { openCommandPalette(); });
        new QShortcut(QKeySequence("Ctrl+Shift+S"), this, [this]() { toggleSplitScreen(); });
        new QShortcut(QKeySequence("Ctrl+Shift+Y"), this, [this]() { takeScreenshot(); });
        new QShortcut(QKeySequence("Ctrl+Shift+V"), this, [this]() { togglePictureInPicture(); });
        new QShortcut(QKeySequence("Ctrl+D"), this, [this]() { bookmarkCurrentPage(); });
        new QShortcut(QKeySequence("Ctrl+Shift+B"), this, [this]() {
            m_bookmarksBarVisible = !m_bookmarksBarVisible;
            m_bookmarksBar->setVisible(m_bookmarksBarVisible);
        });
        new QShortcut(QKeySequence("Ctrl+Alt+R"), this, [this]() { toggleReaderMode(); });
        new QShortcut(QKeySequence("Ctrl+P"), this, [this]() { savePageAsPdf(); });
        new QShortcut(QKeySequence("Ctrl+H"), this, [this]() { m_SideDock->setVisible(!m_SideDock->isVisible()); });
        new QShortcut(QKeySequence("Ctrl+M"), this, [this]() {
            int idx = m_tabs->currentIndex();
            if (auto *v = webViewAt(idx)) {
                v->page()->setAudioMuted(!v->page()->isAudioMuted());
                updateTabIcon(m_tabs->widget(idx), v);
            }
        });
        new QShortcut(QKeySequence("Ctrl+F"), this, [this]() {
            m_findBar->show();
            m_findInput->setFocus();
            m_findInput->selectAll();
        });
        new QShortcut(QKeySequence("Escape"), this, [this]() {
            if (m_findBar->isVisible()) {
                m_findBar->hide();
                if (auto *v = currentWebView()) v->findText("");
            }
        });
        new QShortcut(QKeySequence("F12"), this, [this]() { toggleDevTools(); });
        new QShortcut(QKeySequence::ZoomIn, this, [this]() {
            if (auto *v = currentWebView()) v->setZoomFactor(v->zoomFactor() + 0.1);
        });
        new QShortcut(QKeySequence::ZoomOut, this, [this]() {
            if (auto *v = currentWebView()) v->setZoomFactor(v->zoomFactor() - 0.1);
        });
        new QShortcut(QKeySequence("Ctrl+0"), this, [this]() {
            if (auto *v = currentWebView()) v->setZoomFactor(1.0);
        });
    }

    bool m_isIncognito;
    bool m_bookmarksBarVisible = true;
    QSqlDatabase m_db;
    QString m_userscriptsDir;
    QList<QWebEngineScript> m_loadedUserscripts;
    QMap<QString, QWebEngineProfile *> m_containerProfiles;
    BrowserTabView *m_lastFocusedView = nullptr;
    QStack<QUrl> m_closedTabs;
    QNetworkAccessManager *m_suggestNetManager = nullptr;
    QTimer *m_suggestDebounce = nullptr;
    QWebEngineProfile *m_profile = nullptr;
    AdBlockInterceptor *m_adBlocker = nullptr;
    QAction *m_adBlockAction = nullptr;
    QAction *m_securityAction = nullptr;
    QToolBar *m_navBar = nullptr;
    QToolBar *m_bookmarksBar = nullptr;
    QToolBar *m_findBar = nullptr;
    QLineEdit *m_urlBar = nullptr;
    QCompleter *m_urlCompleter = nullptr;
    QStandardItemModel *m_completerModel = nullptr;
    QLineEdit *m_findInput = nullptr;
    QLineEdit *m_historySearch = nullptr;
    QTabWidget *m_tabs = nullptr;
    QProgressBar *m_progressBar = nullptr;
    QDockWidget *m_SideDock = nullptr;
    QListWidget *m_historyList = nullptr;
    QListWidget *m_bookmarksList = nullptr;
    QListWidget *m_downloadsList = nullptr;
    QListWidget *m_userscriptsList = nullptr;
    QAction *m_backAction = nullptr;
    QAction *m_forwardAction = nullptr;
    QAction *m_reloadAction = nullptr;
};

QWebEngineView *BrowserTabView::createWindow(QWebEnginePage::WebWindowType /*type*/) {
    return m_mainWindow->addNewTab(QUrl());
}

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    app.setApplicationName("ModernQtBrowser");
    app.setDesktopFileName("modernqtbrowser");

    BrowserWindow window(false);
    window.show();

    return app.exec();
}

#include "main.moc"
EOF

    info "Writing packaging/modernqtbrowser.desktop & LICENSE.txt..."
    cat << 'EOF' > "${PROJECT_DIR}/packaging/modernqtbrowser.desktop"
[Desktop Entry]
Type=Application
Name=ModernQtBrowser
Comment=Modern Qt6 WebEngine Browser v3.0 (Native KDE Edition)
Exec=ModernQtBrowser %U
Icon=modernqtbrowser
Terminal=false
Categories=Network;WebBrowser;Qt;KDE;
MimeType=text/html;application/pdf;x-scheme-handler/http;x-scheme-handler/https;
EOF

    cat << 'EOF' > "${PROJECT_DIR}/packaging/LICENSE.txt"
MIT License

Copyright (c) 2026 ModernQtBrowser

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.
EOF

    info "Generating 256x256 PNG icon at packaging/icon.png..."
    if command -v convert >/dev/null 2>&1; then
        convert -size 256x256 xc:#1e1e2e -fill "#3daee9" -draw "circle 128,128 128,32" "${PROJECT_DIR}/packaging/icon.png"
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "${PROJECT_DIR}/packaging/icon.png" << 'PYEOF'
import sys, struct, zlib
def make_png(path, width=256, height=256):
    raw = b"".join(b"\x00" + b"\x3d\xae\xe9\xff" * width for _ in range(height))
    def chunk(tag, data):
        return struct.pack("!I", len(data)) + tag + data + struct.pack("!I", zlib.crc32(tag + data) & 0xffffffff)
    ihdr = struct.pack("!IIBBBBB", width, height, 8, 6, 0, 0, 0)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))
make_png(sys.argv[1])
PYEOF
    else
        base64 -d << 'B64EOF' > "${PROJECT_DIR}/packaging/icon.png"
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
B64EOF
    fi

    success "All v3.0 project files generated in ./${PROJECT_DIR}/"
}

# ------------------------------------------------------------------------------
# 2. Install Linux System Dependencies (Includes Breeze Icons & SQLite Driver)
# ------------------------------------------------------------------------------
install_linux_deps() {
    info "Detecting Linux distribution..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y build-essential cmake ninja-build wget file imagemagick \
                            qt6-base-dev qt6-webengine-dev libqt6sql6-sqlite qmake6 breeze-icon-theme
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y gcc-c++ cmake ninja-build wget file ImageMagick \
                            qt6-qtbase-devel qt6-qtwebengine-devel breeze-icon-theme
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --needed base-devel cmake ninja wget file imagemagick \
                                 qt6-base qt6-webengine breeze-icons
    else
        err "Unsupported package manager. Please install Qt6 WebEngine, CMake, and Ninja manually."
        return 1
    fi
    success "Linux build dependencies installed!"
}

# ------------------------------------------------------------------------------
# 3. Build Native Linux Binary
# ------------------------------------------------------------------------------
build_linux_binary() {
    generate_project_files
    info "Configuring and compiling Linux Release build..."
    mkdir -p "${PROJECT_DIR}/build"
    pushd "${PROJECT_DIR}/build" >/dev/null

    if command -v ninja >/dev/null 2>&1; then
        cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
    else
        cmake -DCMAKE_BUILD_TYPE=Release ..
    fi
    cmake --build . --parallel
    popd >/dev/null
    success "Linux binary compiled at: ${PROJECT_DIR}/build/ModernQtBrowser"
}

# ------------------------------------------------------------------------------
# 4. Build Portable Linux AppImage
# ------------------------------------------------------------------------------
build_linux_appimage() {
    generate_project_files
    info "Building Release binary and staging AppDir..."
    mkdir -p "${PROJECT_DIR}/build"
    pushd "${PROJECT_DIR}/build" >/dev/null

    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
    cmake --build . --parallel
    DESTDIR=AppDir cmake --install .

    info "Downloading linuxdeploy and linuxdeploy-plugin-qt..."
    wget -c -q --show-progress https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
    wget -c -q --show-progress https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
    chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-qt-x86_64.AppImage

    export QMAKE=$(command -v qmake6 || command -v qmake)
    info "Packaging AppImage using QMAKE=${QMAKE}..."
    ./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin qt --output appimage

    popd >/dev/null
    success "AppImage created in ${PROJECT_DIR}/build/!"
}

# ------------------------------------------------------------------------------
# 5. Build Windows Executable & NSIS Installer
# ------------------------------------------------------------------------------
build_windows_installer() {
    generate_project_files
    echo ""
    read -r -p "Enter your Qt6 MSVC path [${QT_WIN_DEFAULT}]: " USER_QT_PATH
    QT_PATH="${USER_QT_PATH:-$QT_WIN_DEFAULT}"

    info "Configuring Windows build with Qt at: ${QT_PATH}..."
    mkdir -p "${PROJECT_DIR}/build"
    pushd "${PROJECT_DIR}/build" >/dev/null

    cmake .. -DCMAKE_PREFIX_PATH="${QT_PATH}"
    cmake --build . --config Release --parallel

    if [ -f "${QT_PATH}/bin/windeployqt.exe" ] && [ -f "./Release/ModernQtBrowser.exe" ]; then
        info "Running windeployqt on Release/ModernQtBrowser.exe..."
        "${QT_PATH}/bin/windeployqt.exe" --release "./Release/ModernQtBrowser.exe"
    fi

    if command -v cpack >/dev/null 2>&1; then
        info "Running CPack to build NSIS & ZIP packages..."
        cpack -G "NSIS;ZIP" -C Release || warn "NSIS not found in PATH; verify NSIS is installed."
    fi

    popd >/dev/null
    success "Windows build & packaging complete inside ${PROJECT_DIR}/build/!"
}

# ------------------------------------------------------------------------------
# 6. Run Compiled Browser
# ------------------------------------------------------------------------------
run_browser() {
    if [ -x "${PROJECT_DIR}/build/ModernQtBrowser" ]; then
        info "Launching Linux ModernQtBrowser v3.0..."
        "./${PROJECT_DIR}/build/ModernQtBrowser" &
    elif [ -f "${PROJECT_DIR}/build/Release/ModernQtBrowser.exe" ]; then
        info "Launching Windows ModernQtBrowser.exe..."
        "./${PROJECT_DIR}/build/Release/ModernQtBrowser.exe" &
    else
        warn "No compiled binary found yet! Please run a Build option first."
    fi
}

# ------------------------------------------------------------------------------
# 7. Clean Build Directory
# ------------------------------------------------------------------------------
clean_build() {
    if [ -d "${PROJECT_DIR}/build" ]; then
        rm -rf "${PROJECT_DIR}/build"
        success "Cleaned ${PROJECT_DIR}/build directory."
    else
        info "Nothing to clean."
    fi
}

# ------------------------------------------------------------------------------
# Interactive UI Menu (Supports Whiptail TUI or Styled ANSI Menu)
# ------------------------------------------------------------------------------
choose_action() {
    if command -v whiptail >/dev/null 2>&1; then
        CHOICE=$(whiptail --title "ModernQtBrowser v3.0 (KDE Edition) - Builder" \
            --menu "Choose an action to perform:" 20 76 10 \
            "1" "Generate / Update Project Source Files Only" \
            "2" "Install Linux Dependencies (apt / dnf / pacman)" \
            "3" "Build Native Linux Binary (Release)" \
            "4" "Build Portable Linux .AppImage" \
            "5" "Build Windows .exe + NSIS Installer (MSVC)" \
            "6" "Launch Compiled ModernQtBrowser" \
            "7" "Clean Build Directory" \
            "0" "Exit" 3>&1 1>&2 2>&3) || CHOICE="0"
    else
        echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${BLUE}║${RESET}   ${BOLD}🌐 ModernQtBrowser v3.0 (KDE Edition) - Automated Builder${RESET}      ${BLUE}║${RESET}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════╣${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}1)${RESET} Generate / Update Project Source Files Only                ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}2)${RESET} Install Linux Dependencies (Ubuntu / Fedora / Arch)        ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}3)${RESET} Build Native Linux Executable (Release)                    ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}4)${RESET} Build Portable Linux ${GREEN}.AppImage${RESET}                              ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}5)${RESET} Build Windows ${GREEN}.exe + NSIS Installer${RESET} (Git Bash / MSVC)     ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}6)${RESET} Launch Compiled ModernQtBrowser                            ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${CYAN}7)${RESET} Clean Build Artifacts                                      ${BLUE}║${RESET}"
        echo -e "${BLUE}║${RESET}  ${RED}0)${RESET} Exit                                                       ${BLUE}║${RESET}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${RESET}"
        read -r -p "Select an option [0-7]: " CHOICE
    fi
}

# ------------------------------------------------------------------------------
# Main Event Loop
# ------------------------------------------------------------------------------
while true; do
    choose_action
    case "$CHOICE" in
        1) generate_project_files ;;
        2) install_linux_deps ;;
        3) build_linux_binary ;;
        4) build_linux_appimage ;;
        5) build_windows_installer ;;
        6) run_browser ;;
        7) clean_build ;;
        0|"") info "Exiting builder. Happy browsing!"; exit 0 ;;
        *) warn "Invalid selection: $CHOICE" ;;
    esac

    echo ""
    read -r -p "Press [Enter] to return to the menu..." _
done
