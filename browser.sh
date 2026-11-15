#!/usr/bin/env bash
set -e

# ==============================================================================
# ModernQtBrowser - Automated Project Generator & Build TUI
# Full Suite: KDE Native UI + AdBlocker + Bundles A, B & C
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

    info "Writing CMakeLists.txt..."
    cat << 'EOF' > "${PROJECT_DIR}/CMakeLists.txt"
cmake_minimum_required(VERSION 3.16)
project(ModernQtBrowser VERSION 2.0.0 LANGUAGES CXX)

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
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Native Qt6 & KDE Theme Chromium Web Browser with AdBlocker")
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

    info "Writing full-featured main.cpp (Bundles A, B, and C integrated)..."
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

#if QT_VERSION >= QT_VERSION_CHECK(6, 8, 0)
#include <QWebEnginePermission>
#endif

class BrowserWindow;

// ----------------------------------------------------------------------------
// Network-Level Ad & Tracker Blocker with EasyList Auto-Updater
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

    void updateFilterLists() {
        const QUrl easyListUrl("https://easylist.to/easylist/easylist.txt");
        QNetworkRequest req(easyListUrl);
        req.setHeader(QNetworkRequest::UserAgentHeader, "ModernQtBrowser/2.0");

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
        if (host.isEmpty()) return;

        if (info.resourceType() == QWebEngineUrlRequestInfo::ResourceTypePing) {
            blockRequest(info, host);
            return;
        }

        QReadLocker locker(&m_lock);

        if (matchesDomainSet(host, m_exceptionDomains)) {
            return;
        }

        if (matchesDomainSet(host, m_blockedDomains)) {
            locker.unlock();
            blockRequest(info, host);
            return;
        }

        const bool isThirdParty = !firstParty.host().isEmpty() &&
                                  !host.endsWith(registeredDomain(firstParty.host().toLower()));

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
    QStringList m_blockedUrlPatterns;

    std::atomic<bool> m_enabled{true};
    std::atomic<int> m_blockedCount{0};
};

// ----------------------------------------------------------------------------
// Custom WebView: Enables PDF Viewer, Screen Capture & New Tab Popups
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
    }

protected:
    QWebEngineView *createWindow(QWebEnginePage::WebWindowType type) override;

private:
    BrowserWindow *m_mainWindow;
    QWebEngineProfile *m_profile;
};

// ----------------------------------------------------------------------------
// Main Browser Window (KDE Plasma Theme + Bundles A, B & C)
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
        resize(1320, 860);

        if (m_isIncognito) {
            m_profile = new QWebEngineProfile(this);
        } else {
            m_profile = new QWebEngineProfile("ModernQtBrowserProfile", this);
            m_profile->setPersistentCookiesPolicy(QWebEngineProfile::AllowPersistentCookies);
        }

        connect(m_profile, &QWebEngineProfile::downloadRequested,
                this, &BrowserWindow::onDownloadRequested);

        // Configure live search autocomplete debounce timer (180ms)
        m_suggestDebounce->setSingleShot(true);
        m_suggestDebounce->setInterval(180);
        connect(m_suggestDebounce, &QTimer::timeout, this, &BrowserWindow::fetchLiveSearchSuggestions);

        setupUI();
        setupShortcuts();
        loadStoredData();
        syncWebThemeWithSystemPalette();

        m_adBlocker = new AdBlockInterceptor(this);
        m_profile->setUrlRequestInterceptor(m_adBlocker);
        injectCosmeticFilter();

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

        // Bundle A: Restore previous session tabs (or open Speed Dial if none/Private)
        if (!restoreSession()) {
            addNewTab(QUrl("about:newtab"));
        }
    }

    BrowserTabView *addNewTab(const QUrl &url = QUrl("about:newtab")) {
        QSplitter *tabSplitter = new QSplitter(Qt::Vertical, this);
        BrowserTabView *webView = new BrowserTabView(m_profile, this, tabSplitter);

        webView->page()->setBackgroundColor(palette().color(QPalette::Base));
        tabSplitter->addWidget(webView);

        int index = m_tabs->addTab(tabSplitter,
                                   themeIcon("text-html", QStyle::SP_FileIcon),
                                   "New Tab");
        m_tabs->setCurrentIndex(index);

        connect(webView, &QWebEngineView::titleChanged, this, [this, tabSplitter, webView](const QString &title) {
            int idx = m_tabs->indexOf(tabSplitter);
            if (idx != -1) {
                if (isTabPinned(idx)) {
                    m_tabs->setTabText(idx, QString());
                    m_tabs->setTabToolTip(idx, title + " (Pinned)");
                } else {
                    QString shortTitle = title.left(24) + (title.length() > 24 ? "..." : "");
                    m_tabs->setTabText(idx, shortTitle.isEmpty() ? "New Tab" : shortTitle);
                    m_tabs->setTabToolTip(idx, title);
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

        // Bundle C: Hardware & Feature Permission Prompts (Camera, Mic, Geolocation, Notifications, Screen Share)
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

        // Bundle B: Load Speed Dial dashboard on about:newtab
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
            syncWebThemeWithSystemPalette();
            // Refresh any open Speed Dial tabs so their colors match the new KDE palette
            for (int i = 0; i < m_tabs->count(); ++i) {
                if (auto *v = webViewAt(i)) {
                    if (v->url().toString() == "about:newtab") loadSpeedDial(v);
                }
            }
        }
        QMainWindow::changeEvent(event);
    }

    // Bundle A: Save open tabs & pinned states on window close
    void closeEvent(QCloseEvent *event) override {
        saveSession();
        saveStoredData();
        QMainWindow::closeEvent(event);
    }

private slots:
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

    void closeTab(int index) {
        if (index < 0 || index >= m_tabs->count()) return;

        if (isTabPinned(index)) {
            statusBar()->showMessage("Tab is pinned. Unpin it first to close.", 2500);
            return;
        }

        // Bundle A: Push closed tab URL onto the undo stack for Ctrl+Shift+T
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
        m_tabs->removeTab(index);
        widget->deleteLater();
    }

    // Bundle A: Reopen most recently closed tab (Ctrl+Shift+T)
    void restoreClosedTab() {
        if (m_closedTabs.isEmpty()) {
            statusBar()->showMessage("No recently closed tabs to reopen", 2500);
            return;
        }
        QUrl url = m_closedTabs.pop();
        addNewTab(url);
        statusBar()->showMessage("Reopened closed tab: " + url.toString(), 2500);
    }

    // Bundle A: Hibernate (Discard) background tab to free Chromium RAM
    void hibernateTab(int index) {
        BrowserTabView *webView = webViewAt(index);
        if (!webView) return;

        if (m_tabs->currentIndex() == index) {
            if (m_tabs->count() <= 1) {
                statusBar()->showMessage("Open another tab before hibernating the active tab.", 3000);
                return;
            }
            // Switch to an adjacent tab before discarding the active tab's renderer
            int nextIdx = (index == 0) ? 1 : index - 1;
            m_tabs->setCurrentIndex(nextIdx);
        }

        webView->page()->setLifecycleState(QWebEnginePage::LifecycleState::Discarded);
        updateTabIcon(m_tabs->widget(index), webView);
        statusBar()->showMessage("Tab hibernated — memory freed until clicked", 3000);
    }

    // Bundle C: Toggle Distraction-Free Reader Mode
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

    // Bundle C: Print / Export Current Page to PDF (Ctrl+P)
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

    // Bundle B: Fetch Live DuckDuckGo Search Autocomplete Suggestions
    void fetchLiveSearchSuggestions() {
        const QString query = m_urlBar->text().trimmed();
        if (query.length() < 2 || query.contains("://") || query.contains(" | ")) {
            return;
        }

        QUrl apiUrl("https://ac.duckduckgo.com/ac/");
        QUrlQuery urlQuery;
        urlQuery.addQueryItem("q", query);
        urlQuery.addQueryItem("type", "list");
        apiUrl.setQuery(urlQuery);

        QNetworkRequest req(apiUrl);
        req.setHeader(QNetworkRequest::UserAgentHeader, "ModernQtBrowser/2.0");
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
            addNewTab(webView->url());
            m_tabs->tabBar()->moveTab(m_tabs->count() - 1, index + 1);
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

        // Bundle A: Hibernate Tab option
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
            splitter->setSizes({500, 300});
        }
    }

    void bookmarkCurrentPage() {
        BrowserTabView *view = currentWebView();
        if (!view || view->url().toString() == "about:newtab") return;
        QString entry = QString("%1 | %2").arg(view->title(), view->url().toString());
        if (m_bookmarksList->findItems(entry, Qt::MatchExactly).isEmpty()) {
            m_bookmarksList->addItem(entry);
            saveStoredData();
            rebuildOmniboxCompletions();
            rebuildBookmarksBar();
            statusBar()->showMessage("Bookmark added to Library and Bookmarks Bar", 2500);
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
        if (auto *splitter = currentSplitter()) {
            return qobject_cast<BrowserTabView *>(splitter->widget(0));
        }
        return nullptr;
    }

    BrowserTabView *webViewAt(int index) const {
        if (auto *splitter = qobject_cast<QSplitter *>(m_tabs->widget(index))) {
            return qobject_cast<BrowserTabView *>(splitter->widget(0));
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

    // Bundle B: Generate and load KDE-Palette-Synced Speed Dial New Tab Page
    void loadSpeedDial(BrowserTabView *webView) {
        if (!webView) return;

        const QString winBg = palette().color(QPalette::Window).name();
        const QString cardBg = palette().color(QPalette::Base).name();
        const QString textFg = palette().color(QPalette::Text).name();
        const QString accent = palette().color(QPalette::Highlight).name();

        QString cardsHtml;
        // Populate cards from user's bookmarks first
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

        // Seed default speed-dial cards if user has fewer than 4 bookmarks
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
                    h1 { font-size: 28px; font-weight: 600; margin-bottom: 24px; letter-spacing: -0.5px; }
                    form { width: 100%; max-width: 580px; margin-bottom: 40px; }
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
                <form action="https://duckduckgo.com/" method="GET">
                    <input type="text" name="q" placeholder="Search DuckDuckGo or type a URL..." autofocus />
                </form>
                <div class="grid">%5</div>
            </body>
            </html>
        )").arg(winBg, cardBg, textFg, accent, cardsHtml);

        webView->setHtml(html, QUrl("about:newtab"));
    }

    // Bundle B: Rebuild Horizontal Bookmarks Toolbar
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

    // Bundle B: Rebuild Omnibox QCompleter (Live Search + Bookmarks + History)
    void rebuildOmniboxCompletions(const QStringList &liveSearchPhrases = {}) {
        if (!m_completerModel) return;
        m_completerModel->clear();

        QSet<QString> seenUrls;

        // 1. Add Live DuckDuckGo Search Suggestions first
        const QIcon searchIcon = themeIcon("edit-find", QStyle::SP_FileDialogContentsView);
        for (const QString &phrase : liveSearchPhrases) {
            const QString searchUrl = "https://duckduckgo.com/?q=" + QUrl::toPercentEncoding(phrase);
            auto *item = new QStandardItem(searchIcon, QString("%1 — Search DuckDuckGo | %2").arg(phrase, searchUrl));
            item->setData(searchUrl, Qt::UserRole);
            m_completerModel->appendRow(item);
        }

        // 2. Add Bookmarks
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

        // 3. Add History
        const QIcon historyIcon = themeIcon("view-history", QStyle::SP_FileDialogInfoView);
        for (int i = 0; i < m_historyList->count(); ++i) {
            const QString raw = m_historyList->item(i)->text();
            const QString url = raw.section(" | ", -1).trimmed();
            QString titlePart = raw.section(" | ", 0, -2).trimmed();

            int bracketEnd = titlePart.indexOf("] ");
            if (bracketEnd != -1) {
                titlePart = titlePart.mid(bracketEnd + 2);
            }

            if (url.isEmpty() || seenUrls.contains(url)) continue;
            seenUrls.insert(url);

            auto *item = new QStandardItem(historyIcon, QString("%1 | %2").arg(titlePart, url));
            item->setData(url, Qt::UserRole);
            m_completerModel->appendRow(item);
        }
    }

    // Bundle A: Save & Restore Open Session Tabs
    void saveSession() {
        if (m_isIncognito) return;
        QSettings settings("ModernQt", "BrowserData");
        QStringList urls;
        QList<QVariant> pinnedFlags;
        for (int i = 0; i < m_tabs->count(); ++i) {
            if (auto *v = webViewAt(i)) {
                QString u = v->url().toString();
                urls << (u.isEmpty() ? "about:newtab" : u);
                pinnedFlags << isTabPinned(i);
            }
        }
        settings.setValue("session_urls", urls);
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
        QList<QVariant> pinnedFlags = settings.value("session_pinned").toList();
        if (urls.isEmpty()) return false;

        for (int i = 0; i < urls.size(); ++i) {
            addNewTab(QUrl(urls[i]));
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

    void syncWebThemeWithSystemPalette() {
        const bool isDarkTheme = palette().color(QPalette::Window).lightness() < 128;
        if (auto *v = currentWebView()) {
            v->page()->setBackgroundColor(palette().color(QPalette::Base));
        }
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

        for (const auto &s : m_profile->scripts()->find("SystemColorSchemeSync")) {
            m_profile->scripts()->remove(s);
        }
        m_profile->scripts()->insert(darkSchemeScript);
    }

    void injectCosmeticFilter() {
        QWebEngineScript script;
        script.setName("CosmeticAdBlock");
        script.setInjectionPoint(QWebEngineScript::DocumentReady);
        script.setWorldId(QWebEngineScript::ApplicationWorld);
        script.setRunsOnSubFrames(true);
        script.setSourceCode(R"(
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
        m_profile->scripts()->insert(script);
    }

    void recordHistory(const QString &title, const QUrl &url) {
        if (url.toString().isEmpty() || url.scheme() == "about") return;
        QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm");
        QString entry = QString("[%1] %2 | %3").arg(timestamp, title, url.toString());
        m_historyList->insertItem(0, entry);
        saveStoredData();
        rebuildOmniboxCompletions();
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

        // 2. Omnibox with Live Search Autocomplete, Reader Mode, Bookmark & AdBlocker
        m_urlBar = new QLineEdit(this);
        m_urlBar->setClearButtonEnabled(true);
        m_urlBar->setPlaceholderText("Search DuckDuckGo or enter address...");
        connect(m_urlBar, &QLineEdit::returnPressed, this, &BrowserWindow::navigateToInput);
        connect(m_urlBar, &QLineEdit::textEdited, this, [this](const QString &) {
            m_suggestDebounce->start();
        });

        m_completerModel = new QStandardItemModel(this);
        m_urlCompleter = new QCompleter(m_completerModel, this);
        m_urlCompleter->setCaseSensitivity(Qt::CaseInsensitive);
        m_urlCompleter->setFilterMode(Qt::MatchContains);
        m_urlCompleter->setCompletionMode(QCompleter::PopupCompletion);
        m_urlCompleter->setMaxVisibleItems(10);
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

        // Bundle C: Reader Mode Toggle Action inside Omnibox
        QAction *readerInlineAction = m_urlBar->addAction(
            themeIcon("view-readermode", QStyle::SP_FileDialogContentsView), QLineEdit::TrailingPosition);
        readerInlineAction->setToolTip("Toggle Distraction-Free Reader Mode (Ctrl+Alt+R)");
        connect(readerInlineAction, &QAction::triggered, this, &BrowserWindow::toggleReaderMode);

        // Bookmark Star Action inside Omnibox
        QAction *bookmarkInlineAction = m_urlBar->addAction(
            themeIcon("bookmarks", QStyle::SP_DialogYesButton), QLineEdit::TrailingPosition);
        bookmarkInlineAction->setToolTip("Bookmark this page (Ctrl+D)");
        connect(bookmarkInlineAction, &QAction::triggered, this, &BrowserWindow::bookmarkCurrentPage);

        // AdBlock Shield Action inside Omnibox
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

        // 3. Right-side Toolbar Buttons
        m_navBar->addAction(
            themeIcon("view-sidetree", QStyle::SP_FileDialogDetailedView),
            "Toggle Library Sidebar (Ctrl+H)", this, [this]() {
                m_SideDock->setVisible(!m_SideDock->isVisible());
            });

        m_navBar->addAction(
            themeIcon("view-private", QStyle::SP_DialogResetButton),
            "New Private Window", this, []() {
                auto *win = new BrowserWindow(true);
                win->show();
            });

        QToolButton *menuButton = new QToolButton(this);
        menuButton->setIcon(themeIcon("application-menu", QStyle::SP_TitleBarMenuButton));
        menuButton->setToolTip("Menu");
        menuButton->setPopupMode(QToolButton::InstantPopup);

        QMenu *appMenu = new QMenu(menuButton);
        appMenu->addAction(themeIcon("tab-new", QStyle::SP_FileDialogNewFolder), "New Tab\tCtrl+T", this, [this]() { addNewTab(); });
        appMenu->addAction(themeIcon("edit-undo", QStyle::SP_ArrowBack), "Reopen Closed Tab\tCtrl+Shift+T", this, [this]() { restoreClosedTab(); });
        appMenu->addAction(themeIcon("view-private", QStyle::SP_DialogResetButton), "New Private Window", this, []() {
            (new BrowserWindow(true))->show();
        });
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("bookmarks", QStyle::SP_DialogYesButton), "Toggle Bookmarks Bar\tCtrl+Shift+B", this, [this]() {
            m_bookmarksBarVisible = !m_bookmarksBarVisible;
            m_bookmarksBar->setVisible(m_bookmarksBarVisible);
        });
        appMenu->addAction(themeIcon("view-readermode", QStyle::SP_FileDialogContentsView), "Toggle Reader Mode\tCtrl+Alt+R", this, [this]() {
            toggleReaderMode();
        });
        appMenu->addAction(themeIcon("document-print", QStyle::SP_DialogSaveButton), "Save Page as PDF...\tCtrl+P", this, [this]() {
            savePageAsPdf();
        });
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("edit-find", QStyle::SP_FileDialogContentsView), "Find in Page...\tCtrl+F", this, [this]() {
            m_findBar->show();
            m_findInput->setFocus();
            m_findInput->selectAll();
        });
        appMenu->addAction(themeIcon("tools-wizard", QStyle::SP_ComputerIcon), "Developer Tools\tF12", this, [this]() {
            toggleDevTools();
        });
        appMenu->addSeparator();
        appMenu->addAction(themeIcon("application-exit", QStyle::SP_DialogCloseButton), "Quit\tCtrl+Q", qApp, &QApplication::closeAllWindows);
        menuButton->setMenu(appMenu);
        m_navBar->addWidget(menuButton);

        // 4. Bundle B: Secondary Bookmarks Toolbar (Ctrl+Shift+B)
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

        // 6. Central Native QTabWidget with Context Menu & Corner "+ New Tab" Button
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
        newTabButton->setToolTip("Open a new tab (Ctrl+T)");
        newTabButton->setAutoRaise(true);
        connect(newTabButton, &QToolButton::clicked, this, [this]() { addNewTab(); });
        m_tabs->setCornerWidget(newTabButton, Qt::TopRightCorner);

        connect(m_tabs, &QTabWidget::tabCloseRequested, this, &BrowserWindow::closeTab);
        connect(m_tabs, &QTabWidget::currentChanged, this, [this](int index) {
            if (auto *v = currentWebView()) {
                // Wake up tab if it was hibernated
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

        // 7. Native Status Bar & Slim Progress Indicator
        m_progressBar = new QProgressBar(this);
        m_progressBar->setMaximumWidth(140);
        m_progressBar->setMaximumHeight(12);
        m_progressBar->setTextVisible(false);
        statusBar()->addPermanentWidget(m_progressBar);

        // 8. Native QDockWidget for History, Bookmarks & Downloads
        m_SideDock = new QDockWidget("Library", this);
        QTabWidget *dockTabs = new QTabWidget(m_SideDock);
        dockTabs->setDocumentMode(true);

        QWidget *historyPage = new QWidget();
        QVBoxLayout *histLayout = new QVBoxLayout(historyPage);
        m_historySearch = new QLineEdit();
        m_historySearch->setClearButtonEnabled(true);
        m_historySearch->setPlaceholderText("Filter history...");
        m_historyList = new QListWidget();
        m_historyList->setAlternatingRowColors(true);
        QPushButton *clearHistBtn = new QPushButton(themeIcon("edit-clear-history", QStyle::SP_TrashIcon), "Clear History");
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
            saveStoredData();
            rebuildOmniboxCompletions();
        });

        m_bookmarksList = new QListWidget();
        m_bookmarksList->setAlternatingRowColors(true);
        connect(m_bookmarksList, &QListWidget::itemDoubleClicked, this, [this](QListWidgetItem *item) {
            QString urlStr = item->text().section(" | ", -1);
            addNewTab(QUrl(urlStr));
        });

        m_downloadsList = new QListWidget();
        m_downloadsList->setAlternatingRowColors(true);

        dockTabs->addTab(historyPage, themeIcon("view-history", QStyle::SP_FileDialogInfoView), "History");
        dockTabs->addTab(m_bookmarksList, themeIcon("bookmarks", QStyle::SP_DialogYesButton), "Bookmarks");
        dockTabs->addTab(m_downloadsList, themeIcon("folder-download", QStyle::SP_ArrowDown), "Downloads");

        m_SideDock->setWidget(dockTabs);
        addDockWidget(Qt::LeftDockWidgetArea, m_SideDock);
        m_SideDock->hide();
    }

    void setupShortcuts() {
        new QShortcut(QKeySequence("Ctrl+T"), this, [this]() { addNewTab(); });
        new QShortcut(QKeySequence("Ctrl+Shift+T"), this, [this]() { restoreClosedTab(); });
        new QShortcut(QKeySequence("Ctrl+W"), this, [this]() { closeTab(m_tabs->currentIndex()); });
        new QShortcut(QKeySequence("Ctrl+L"), this, [this]() { m_urlBar->setFocus(); m_urlBar->selectAll(); });
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

    void loadStoredData() {
        if (m_isIncognito) return;
        QSettings settings("ModernQt", "BrowserData");
        m_historyList->addItems(settings.value("history").toStringList());
        m_bookmarksList->addItems(settings.value("bookmarks").toStringList());
        rebuildOmniboxCompletions();
        rebuildBookmarksBar();
    }

    void saveStoredData() {
        if (m_isIncognito) return;
        QSettings settings("ModernQt", "BrowserData");
        QStringList hist, marks;
        for (int i = 0; i < qMin(m_historyList->count(), 500); ++i)
            hist << m_historyList->item(i)->text();
        for (int i = 0; i < m_bookmarksList->count(); ++i)
            marks << m_bookmarksList->item(i)->text();
        settings.setValue("history", hist);
        settings.setValue("bookmarks", marks);
    }

    bool m_isIncognito;
    bool m_bookmarksBarVisible = true;
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
Comment=Modern Qt6 WebEngine Browser (Native KDE Edition)
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

    success "All project files generated in ./${PROJECT_DIR}/"
}

# ------------------------------------------------------------------------------
# 2. Install Linux System Dependencies (Includes Breeze Icons)
# ------------------------------------------------------------------------------
install_linux_deps() {
    info "Detecting Linux distribution..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y build-essential cmake ninja-build wget file imagemagick \
                            qt6-base-dev qt6-webengine-dev qmake6 breeze-icon-theme
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
        info "Launching Linux ModernQtBrowser..."
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
        CHOICE=$(whiptail --title "ModernQtBrowser v2.0 (KDE Edition) - Builder" \
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
        echo -e "${BLUE}║${RESET}   ${BOLD}🌐 ModernQtBrowser v2.0 (KDE Edition) - Automated Builder${RESET}      ${BLUE}║${RESET}"
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
