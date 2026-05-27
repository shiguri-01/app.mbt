///|
enum ActionButtonKind {
  Primary
  Secondary
  Sidebar
}

///|
struct ActionButtonProps {
  label : String
  title : String
  kind : () -> ActionButtonKind
  on_press : () -> Unit
  disabled : () -> Bool
}

///|
fn action_button_class(kind : ActionButtonKind) -> String {
  match kind {
    Primary => "action-button primary-action"
    Secondary => "action-button secondary-action"
    Sidebar => "action-button sidebar-action"
  }
}

///|
fn action_button(props : ActionButtonProps) -> DomNode {
  button(
    dyn_class=fn() { action_button_class((props.kind)()) },
    attrs=[("title", AttrString(props.title))],
    dyn_attrs=[
      ("disabled", attr_dynamic(fn() { (props.disabled)().to_string() })),
    ],
    on=events().click(_ => if !(props.disabled)() { (props.on_press)() }),
  ) <| [
    text(props.label),
  ]
}

///|
struct ModeButtonProps {
  label : String
  active : () -> Bool
  on_press : () -> Unit
}

///|
fn mode_button_class(active : Bool) -> String {
  if active {
    "mode-button active"
  } else {
    "mode-button"
  }
}

///|
fn mode_button(props : ModeButtonProps) -> DomNode {
  button(
    dyn_class=fn() { mode_button_class((props.active)()) },
    on=events().click(_ => (props.on_press)()),
  ) <| [
    text(props.label),
  ]
}
