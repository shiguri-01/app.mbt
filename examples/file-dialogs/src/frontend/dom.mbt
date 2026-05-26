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
