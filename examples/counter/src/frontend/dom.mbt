///|
#external
type Element

///|
extern "js" fn element_by_id(id : String) -> Element =
  #| (id) => document.getElementById(id)

///|
extern "js" fn Element::set_text(self : Element, text : String) -> Unit =
  #| (element, text) => {
  #|   element.textContent = text
  #| }

///|
extern "js" fn Element::on_click(self : Element, handler : () -> Unit) -> Unit =
  #| (element, handler) => {
  #|   element.addEventListener("click", handler)
  #| }

///|
extern "js" fn set_document_title(title : String) -> Unit =
  #| (title) => {
  #|   document.title = title
  #| }

///|
extern "js" fn post_message(raw : String) -> Unit =
  #| (raw) => {
  #|   if (globalThis.__moonbitDesktopPostMessage) {
  #|     globalThis.__moonbitDesktopPostMessage(raw)
  #|   } else {
  #|     console.log("[desktop ipc pending]", raw)
  #|   }
  #| }
