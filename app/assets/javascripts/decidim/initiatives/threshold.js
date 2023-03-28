document.addEventListener("DOMContentLoaded",function() {
  updateThreshold();
});


// When page contains initiatives, update each progress bar for initiatives which have reached first threshold (100 000)
function updateThreshold() {
  if (window.location.pathname.startsWith("/initiatives")) {
    var seuil_1_str = "100 000";
    var seuil_2_str = "500&nbsp000";

    var seuil_1_int = parseInt(seuil_1_str.replaceAll(" ", ""));
    var seuil_2_int = parseInt(seuil_2_str.replaceAll("&nbsp", ""));

    $('.progress__bar').each(function() {
      var nombre_signatures_str = $(this).find('.progress__bar__number').text();
      var nombre_signatures_int = parseInt(nombre_signatures_str.replaceAll(" ", ""));

      if (nombre_signatures_int >= seuil_1_int) {
        $(this).html($(this).html().replaceAll("/" + seuil_1_str, "/" + seuil_2_str));

        var progress_bar_value_seuil_1 = $(this).find('.progress.progress__bar__bar').attr('aria-valuenow');
        var progress_bar_value_seuil_2 = (nombre_signatures_int / seuil_2_int) * 100;

        $(this).find('.progress.progress__bar__bar').attr('aria-valuenow', progress_bar_value_seuil_2);
        $(this).html($(this).html().replaceAll(progress_bar_value_seuil_1 + " percent", progress_bar_value_seuil_2 + " percent").replaceAll(progress_bar_value_seuil_1 + "%", progress_bar_value_seuil_2 + "%"));
      }
    });
  }
}
