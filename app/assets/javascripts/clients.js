var scollableTable = function() {
  if ($(window).width() < 640) {
    $('.client-table').addClass('scroll');
  } else {
    $('.client-table').removeClass('scroll');
  }
}; 