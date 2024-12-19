import { LinksFunction } from "@remix-run/node";
import {
  isRouteErrorResponse,
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  useRouteError,
} from "@remix-run/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ErrorMessage } from "./components/primitives/error-message/error-message";
import "./tailwind.css";

export function Layout({ children }: { children: React.ReactNode }) {
  const queryClient = new QueryClient();

  return (
    <html lang="ja">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body className="overscroll-none bg-neutral-100">
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
        <ScrollRestoration />
        <Scripts />
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
                instrumentationKey: "0000-0000-0000-0000"
              });
              window.appInsights = appInsights;
              if (appInsights.queue && appInsights.queue.length === 0) {
                appInsights.trackPageView();
              }
              window.appInsights=appInsights,appInsights.queue&&0===appInsights.queue.length&&appInsights.trackPageView();
            `,
          }}
        />
      </body>
    </html>
  );
}

export default function App() {
  return <Outlet />;
}

export function ErrorBoundary() {
  const error = useRouteError();
  return (
    <ErrorMessage>
      {isRouteErrorResponse(error)
        ? `${error.status} ${error.statusText}`
        : error instanceof Error
          ? error.message
          : "Unknown Error"}
    </ErrorMessage>
  );
}

export function HydrateFallback() {
  return <></>;
}

export const links: LinksFunction = () => {
  return [
    {
      rel: "icon",
      href: "/favicon.ico",
      type: "image/ico",
    },
    {
      rel: "icon",
      href: "/favicon-32x32.png",
      type: "image/png",
      sizes: "32x32",
    },
    {
      rel: "icon",
      href: "/favicon-128x128.png",
      type: "image/png",
      sizes: "128x128",
    },
    {
      rel: "apple-touch-icon",
      href: "/apple-touch-icon-180x180.png",
      sizes: "180x18",
    },
  ];
};
