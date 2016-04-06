/**
 * Created by mariomerino on 6/04/16.
 */
// Función que comprueba que los estudiantes/subproyectos del diálogo de selección, han sido ya cargados...
var studentsSelectionAlreadyLoaded = false
$(document).ready(function(){
    $('#all_attributes').on("click", "#loadModalStudentsSelection", function(e) {
        if(studentsSelectionAlreadyLoaded == true){
            showModal('ajax-modal', '1000px');
            $('#button_apply_projects').focus();
            return false;
        }
    });
});