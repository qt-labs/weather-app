/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "winrtcharms.h"

#include <QStringList>

#include <windows.h>
#include <roapi.h>
#include <wrl.h>
#include <windows.ui.popups.h>
#include <windows.ui.applicationsettings.h>
#include <windows.foundation.collections.h>

using namespace Microsoft::WRL;
using namespace Microsoft::WRL::Wrappers;
using namespace ABI::Windows::Foundation;
using namespace ABI::Windows::Foundation::Collections;
using namespace ABI::Windows::UI::ApplicationSettings;
using namespace ABI::Windows::UI::Popups;

class WinRTSettingsCharmPrivate
{
public:
    WinRTSettingsCharmPrivate(WinRTSettingsCharm *q)
        : q_ptr(q)
    {
    }

    ComPtr<ISettingsPane> settingsPane;
    EventRegistrationToken cookie;
    QStringList items;

    HRESULT settingsRequested(ISettingsPane *, ISettingsPaneCommandsRequestedEventArgs *args)
    {
        ComPtr<ISettingsPaneCommandsRequest> request;
        HRESULT hr = args->get_Request(&request);
        if (FAILED(hr)) {
            qErrnoWarning(hr, "Failed to get settings command request.");
            return S_OK;
        }

        ComPtr<IUICommandFactory> factory;
        hr = RoGetActivationFactory(HString::MakeReference(RuntimeClass_Windows_UI_Popups_UICommand).Get(),
                                    IID_PPV_ARGS(&factory));
        if (FAILED(hr)) {
            qErrnoWarning(hr, "Failed to get command factory.");
            return S_OK;
        }

        ComPtr<IVector<SettingsCommand *>> commands;
        hr = request->get_ApplicationCommands(&commands);
        if (FAILED(hr)) {
            qErrnoWarning(hr, "Failed to get command list.");
            return S_OK;
        }

        foreach (const QString &item, items) {
            ComPtr<IUICommand> command;
            HStringReference label(reinterpret_cast<const wchar_t *>(item.utf16()), item.length());
            hr = factory->Create(label.Get(), &command);
            if (FAILED(hr)) {
                qErrnoWarning(hr, "Failed to create UI command.");
                return S_OK;
            }

            hr = command->put_Invoked(Callback<IUICommandInvokedHandler>(
                                                this, &WinRTSettingsCharmPrivate::commandInvoked).Get());
            if (FAILED(hr)) {
                qErrnoWarning(hr, "Failed to set command invoked handler.");
                return S_OK;
            }

            hr = commands->Append(command.Get());
            if (FAILED(hr)) {
                qErrnoWarning(hr, "Failed to append privacy policy command.");
                return S_OK;
            }
        }

        return S_OK;
    }

    HRESULT commandInvoked(IUICommand *command)
    {
        Q_Q(WinRTSettingsCharm);

        HString label;
        HRESULT hr = command->get_Label(label.GetAddressOf());
        if (FAILED(hr)) {
            qErrnoWarning(hr, "Failed to get invoked command label.");
            return S_OK;
        }

        emit q->itemClicked(QString::fromWCharArray(label.GetRawBuffer(Q_NULLPTR)));

        return S_OK;
    }

private:
    WinRTSettingsCharm *q_ptr;
    Q_DECLARE_PUBLIC(WinRTSettingsCharm)
};

WinRTSettingsCharm::WinRTSettingsCharm()
    : d_ptr(new WinRTSettingsCharmPrivate(this))
{
    Q_D(WinRTSettingsCharm);

    ComPtr<ISettingsPaneStatics> factory;
    HRESULT hr = RoGetActivationFactory(Wrappers::HString::MakeReference(RuntimeClass_Windows_UI_ApplicationSettings_SettingsPane).Get(),
                                        IID_PPV_ARGS(&factory));
    if (FAILED(hr)) {
        qErrnoWarning(hr, "Failed to get settings pane factory.");
        return;
    }

    hr = factory->GetForCurrentView(&d->settingsPane);
    if (FAILED(hr)) {
        qErrnoWarning(hr, "Failed to get settings pane from factory.");
        return;
    }

    hr = d->settingsPane->add_CommandsRequested(Callback<ITypedEventHandler<SettingsPane *, SettingsPaneCommandsRequestedEventArgs *>>(
                                                    d, &WinRTSettingsCharmPrivate::settingsRequested).Get(), &d->cookie);
    if (FAILED(hr)) {
        qErrnoWarning(hr, "Failed to add commands requested callback.");
        return;
    }
}

WinRTSettingsCharm::~WinRTSettingsCharm()
{
    Q_D(WinRTSettingsCharm);

    if (!d->settingsPane)
        return;

    HRESULT hr = d->settingsPane->remove_CommandsRequested(d->cookie);
    if (FAILED(hr)) {
        qErrnoWarning(hr, "Failed to remove settings pane callback.");
        return;
    }
}

QStringList WinRTSettingsCharm::items() const
{
    Q_D(const WinRTSettingsCharm);
    return d->items;
}

void WinRTSettingsCharm::addItem(const QString &label)
{
    Q_D(WinRTSettingsCharm);
    d->items.append(label);
}

void WinRTSettingsCharm::removeItem(const QString &label)
{
    Q_D(WinRTSettingsCharm);
    d->items.removeOne(label);
}
