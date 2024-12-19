# azure-fridays-2024-12-20

## Setup

* required Azure subscription and az cli
* Contribute role

```console
$ script/bootstrap

# Check client_id = appId, client_secret = password, tenant_id = tenant
$ cat principal.json

# Set `client_id`, `client_secret`, `tenant_id`, `subscription_id` in variables.auto.pkrvars.hcl
$ cp variables.auto.pkrvars.hcl.sample variables.auto.pkrvars.hcl
$ {EDITOR} variables.auto.pkrvars.hcl

$ packer build .
```

create vm using image on https://portal.azure.com/

* ISUCON14 ref https://github.com/isucon/isucon14
* Create VM Image ref https://github.com/matsuu/aws-isucon/blob/main/isucon14
* Create Image Gallery on Azure ref https://github.com/tsubasaxZZZ/azure-isucon/tree/main/isucon14

## Set up Azure Monitor

- Apps Monitoring, Data Monitoring and Storage and Key Vaults Monitoring: The AzureMetrics and AzureDiagnostics tables are required. This can be achieved through a resource’s diagnostic settings. For detailed instructions, refer to Azure Monitor Essentials: Diagnostic Settings: https://learn.microsoft.com/ja-jp/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal
- Compute Monitoring: The InsightsMetrics table is required. Enable VM Insights by following the instructions provided https://learn.microsoft.com/ja-jp/azure/azure-monitor/vm/vminsights-enable?tabs=portal
- Network Monitoring: The AzureMetrics table is required. This can be achieved through a resource’s diagnostic settings. For detailed instructions, refer to Azure Monitor Essentials: Diagnostic Settings: https://learn.microsoft.com/ja-jp/azure/azure-monitor/essentials/diagnostic-settings#metrics

## Run bench

- login

```console
$ ssh -i xxx azureuser@x.x.x.x
```

- switch isucon user

```console
$ sudo su - isucon
```

- run bench

```conosle
$ ./bench run --addr 127.0.0.1:443 --target https://isuride.xiv.isucon.net --payment-url http://127.0.0.1:12346 --payment-bind-port 12346 -s
```


## Application Insight(Azure Monitor OpenTelemetry Distro) using Python

ref https://learn.microsoft.com/ja-jp/azure/azure-monitor/app/opentelemetry-enable?tabs=python

- login

```console
$ ssh -i xxx azureuser@x.x.x.x
```

- switch isucon user

```console
$ sudo su - isucon
```

- setup

```console
$ cd webapp/python/
$ vim pyproject.toml
+    "azure-monitor-opentelemetry>=1.6.4",
$ /home/isucon/.local/bin/uv lock
$ /home/isucon/.local/bin/uv sync --locked --no-dev

$ vim /home/isucon/env.sh
+ APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://;LiveEndpoint=https://;ApplicationId=00000000-0000-0000-0000-000000000000"
$ sudo service isuride-python restart
```

- Why do we write to the env.sh file?

```
$ sudo cat /etc/systemd/system/isuride-python.service
[Unit]
Description=isuride-python
After=syslog.target
After=mysql.service
Requires=mysql.service

[Service]
WorkingDirectory=/home/isucon/webapp/python
EnvironmentFile=/home/isucon/env.sh # <=============== isuride-python use env.sh

User=isucon
Group=isucon
ExecStart=/home/isucon/webapp/python/.venv/bin/gunicorn
ExecStop=/bin/kill -s QUIT $MAINPID

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Application Insight(Live metrics) using Python

ref https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/monitor/azure-monitor-opentelemetry#usage

```python
configure_azure_monitor(
    enable_live_metrics=True
)
```

## Application Insights for frontend

- login

```console
$ ssh -i xxx azureuser@x.x.x.x
```

- switch isucon user

```console
$ sudo su - isucon
```

- setup pnpm

```console
$ git clone https://github.com/isucon/isucon14
$ cd isucon14/frontend
$ curl -fsSL https://get.pnpm.io/install.sh | sh -
==> Downloading pnpm binaries 9.15.0
 WARN  using --force I sure hope you know what you are doing
Copying pnpm CLI from /tmp/tmp.bm6oVEf9OR/pnpm to /home/isucon/.local/share/pnpm/pnpm
Appended new lines to /home/isucon/.bashrc

Next configuration changes were made:
export PNPM_HOME="/home/isucon/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

To start using pnpm, run:
source /home/isucon/.bashrc
```

- setup Javascript

```console
$ vim app/root.tsx

        <script
          dangerouslySetInnerHTML={{
            __html: `
              var appInsights = window.appInsights || (function (config) {
                function createMethod(name) {
                  appInsights[name] = function () {
                    var args = arguments;
                    appInsights.queue.push(function () {
                      appInsights[name].apply(appInsights, args);
                    });
                  };
                }
                var appInsights = { config: config };
                var document = window.document;
                var window = window;
                setTimeout(function () {
                  var script = document.createElement("script");
                  script.src = config.url || "https://";
                  document.getElementsByTagName("script")[0].parentNode.appendChild(script);
                });
                try {
                  appInsights.cookie = document.cookie;
                } catch (e) {}
                appInsights.queue = [];
                var methods = ["Event", "Exception", "Metric", "PageView", "Trace", "Dependency"];
                while (methods.length) {
                  createMethod("track" + methods.pop());
                }
                createMethod("setAuthenticatedUserContext");
                createMethod("clearAuthenticatedUserContext");
                createMethod("startTrackEvent");
                createMethod("stopTrackEvent");
                createMethod("startTrackPage");
                createMethod("stopTrackPage");
                createMethod("flush");
                if (!config.disableExceptionTracking) {
                  var originalOnError = window.onerror;
                  window.onerror = function (message, url, lineNumber, columnNumber, error) {
                    var handled = originalOnError && originalOnError(message, url, lineNumber, columnNumber, error);
                    if (handled !== true) {
                      appInsights["_onerror"](message, url, lineNumber, columnNumber, error);
                    }
                    return handled;
                  };
                }
                return appInsights;
              })({
                instrumentationKey: "000-0000-0000-0000"
              });
              window.appInsights = appInsights;
              if (appInsights.queue && appInsights.queue.length === 0) {
                appInsights.trackPageView();
              }
              window.appInsights=appInsights,appInsights.queue&&0===appInsights.queue.length&&appInsights.trackPageView();
            `,
          }}
        />
```

- build & deploy

```console
$ pnpm install
$ pnpm run build
$ rm -rf ../../webapp/public
$ cp -rp build/client ../../webapp/public
```
