const TranslationSearch = () => {
  const localeSelectId = 'tlocale'
  const missingControlId = 'translations--search--missing--control'

  const localeSelect = document.getElementById(localeSelectId);
  if ( localeSelect === null ) return;

  localeSelect.addEventListener('change', (e) => {
    let control = e.target
    let selectedLocale = control.options[control.selectedIndex].value
    if (selectedLocale === '') {
      document.getElementById(missingControlId).classList.add('invisible')
    } else {
      document.getElementById(missingControlId).classList.remove('invisible')
    }
  })
}

document.addEventListener("turbolinks:load", TranslationSearch)
