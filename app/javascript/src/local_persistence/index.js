const LocalPersistence = () => {
  const persistedElements = () => {
    let elements = document.getElementsByClassName('persisted-input')
    if (elements == undefined) return [];
    return(elements)
  }

  const updateLocalStorage = (input) => {
    const input_key = input.dataset.persistedKey;
    const input_value = input.value;
    localStorage.setItem(input_key + '_last', Date.now());
    localStorage.setItem(input_key + '_value', input_value);
  }

  const clearLocalStorage = (input) => {
    const input_key = input.dataset.persistedKey;
    localStorage.removeItem(input_key + '_last');
    localStorage.removeItem(input_key + '_value');
  }

  const handleInputChange = (e) => {
    const input = e.target;
    updateLocalStorage(input);
    const alert_box = document.getElementById('unsaved_changes_alert');
    alert_box.style.display = 'block';
  }

  const loadInputData = (input) => {
    const input_key = input.dataset.persistedKey;
    const input_last = input.dataset.persistedLast;
    const input_value = input.value;

    const local_value = localStorage.getItem(input_key + '_value');
    const local_last = localStorage.getItem(input_key + '_last');
    const alert_box = document.getElementById('unsaved_changes_alert');
    let current_value = null;

    if (local_value != undefined && local_last != undefined) {
      if (local_last > input_last) {
        alert_box.style.display = 'block';
        current_value = local_value;
        input.value = current_value;
      }
    }
  }

  const clearCache = (_) => {
    const elements = persistedElements();
    let i;
    for(i=0;i<elements.length;i++) {
      const input = elements[i];
      clearLocalStorage(input);
    }
    const alert_box = document.getElementById('unsaved_changes_alert');
    alert_box.style.display = 'none'
  }

  const elements = persistedElements();
  let i;
  for(i=0;i<elements.length;i++) {
    const input = elements[i];
    loadInputData(input);
    input.addEventListener('change', handleInputChange);
  }

  /*window.onbeforeunload = clearCache;*/

  const clear_unsaved_changes_button = document.getElementById('clear_unsaved_changes');
  if (clear_unsaved_changes_button != undefined) {
    clear_unsaved_changes_button.addEventListener('click', function(e){
      e.preventDefault();
      clearCache(null);
      location.reload();
    })
  }

}
document.addEventListener('turbolinks:load', LocalPersistence);
