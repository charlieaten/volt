defmodule Volt.Plugin.React do
  @moduledoc """
  Built-in React prebundle coordination for Volt dev mode.
  """

  @behaviour Volt.Plugin

  @react_exports ~w(
    Children
    Component
    Fragment
    Profiler
    PureComponent
    StrictMode
    Suspense
    cloneElement
    createContext
    createElement
    createRef
    forwardRef
    isValidElement
    lazy
    memo
    startTransition
    use
    useActionState
    useCallback
    useContext
    useDebugValue
    useDeferredValue
    useEffect
    useId
    useImperativeHandle
    useInsertionEffect
    useLayoutEffect
    useMemo
    useOptimistic
    useReducer
    useRef
    useState
    useSyncExternalStore
    useTransition
    version
  )

  @react_dom_exports ~w(
    __DOM_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE
    createPortal
    flushSync
    preconnect
    prefetchDNS
    preinit
    preinitModule
    preload
    preloadModule
    requestFormReset
    unstable_batchedUpdates
    useFormState
    useFormStatus
  )

  @impl true
  def name, do: "react"

  @impl true
  def prebundle_alias("react-dom/client"), do: "react"
  def prebundle_alias("react/jsx-runtime"), do: "react"
  def prebundle_alias("react/jsx-dev-runtime"), do: "react"
  def prebundle_alias(_specifier), do: nil

  @impl true
  def prebundle_entry("react") do
    {:proxy, "react.js",
     imports: [%{default: "React", from: "react"}],
     exports: [
       %{default: "React"},
       %{members: Enum.map(@react_exports, &{&1, "React.#{&1}"})},
       %{
         named_from: "react-dom/client",
         names: ["createRoot", "hydrateRoot", {"version", "reactDomVersion"}]
       },
       %{named_from: "react-dom", names: @react_dom_exports},
       %{named_from: "react/jsx-runtime", names: ["jsx", "jsxs"]},
       %{named_from: "react/jsx-dev-runtime", names: ["jsxDEV"]}
     ]}
  end

  def prebundle_entry("react-dom") do
    {:source, "react-dom.js", react_dom_entry_source()}
  end

  def prebundle_entry(_specifier), do: nil

  defp react_dom_entry_source do
    members = Enum.join(@react_dom_exports, ", ")

    """
    import { #{members}, reactDomVersion } from "react";

    const ReactDOM = {
      #{members},
      version: reactDomVersion,
    };

    export default ReactDOM;
    export { #{members}, reactDomVersion as version };
    """
  end
end
