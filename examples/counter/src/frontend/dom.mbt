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
  #|   element.addEventListener("click", () => handler())
  #| }

///|
fn Element::on_click_async(self : Element, handler : async () -> Unit) -> Unit {
  self.on_click(() => ignore(@js_async.Promise::from_async(handler)))
}

///|
extern "js" fn set_document_title(title : String) -> Unit =
  #| (title) => {
  #|   document.title = title
  #| }
