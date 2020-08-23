(function () {

  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   *                                                   *
   * Setup all globally access variables and functions *
   *                                                   *
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  /* ~~~~~~~~~~~~~~~~~~~~~~
  * JQuery-Like Shorthands
  ~~~~~~~~~~~~~~~~~~~~~~~~*/
  function $(query) {
    return document.querySelector(query);
  }
  function $$(query) {
    return Array.prototype.slice.call(document.querySelectorAll(query));
  }

  /* ~~~~~~~~~~~~~~
  * Variable Setup
  ~~~~~~~~~~~~~~~~*/

  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~
  * Scroll Progress Controller
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  function scrollProgress(pageHeight, scrollTop) {
    var percentageScroll = ((scrollTop / pageHeight) * 100) + "%";
    document.querySelector("#scroll-progress").style.width = percentageScroll;
  }

  /* ~~~~~~~~~~~~~~~~~~~~
  * Animation Controller
  ~~~~~~~~~~~~~~~~~~~~~~*/
  //Accordion 1 Functionality
  var acc = document.getElementsByClassName("accordion");
  var i;

  // Open the first accordion
  var firstAccordion = acc[0];
  var firstPanel = firstAccordion.nextElementSibling;
  firstAccordion.classList.add("active");
  firstPanel.style.maxHeight = firstPanel.scrollHeight + "px";

  // Add onclick listener to every accordion element
  for (i = 0; i < acc.length; i++) {
    acc[i].onclick = function () {
      // Detect if the clicked section is already "active"
      var isActive = this.classList.contains("active");

      // Close all accordions
      var allAccordions = document.getElementsByClassName("accordion");
      for (j = 0; j < allAccordions.length; j++) {
        // Remove active class from section header
        allAccordions[j].classList.remove("active");

        // Remove the max-height class from the panel to close it
        var panel = allAccordions[j].nextElementSibling;
        var maxHeightValue = getStyle(panel, "maxHeight");

        if (maxHeightValue !== "0px") {
          panel.style.maxHeight = null;
        }
      }

      // Toggle the clicked section using ternary
      isActive ? this.classList.remove("active") : this.classList.add("active");

      // Toggle the panel element
      var panel = this.nextElementSibling;
      var maxHeightValue = getStyle(panel, "maxHeight");

      if (maxHeightValue !== "0px") {
        panel.style.maxHeight = null;
      } else {
        panel.style.maxHeight = panel.scrollHeight + "px";
      }
    };
  }

  //Accordion 2 functionality
  var acc = document.getElementsByClassName("accordion2");
  var i;

  // Open the first accordion
  var firstAccordion = acc[0];
  var firstPanel = firstAccordion.nextElementSibling;
  firstAccordion.classList.add("active2");
  firstPanel.style.maxHeight = firstPanel.scrollHeight + "px";

  // Add onclick listener to every accordion element
  for (i = 0; i < acc.length; i++) {
    acc[i].onclick = function () {
      // Detect if the clicked section is already "active"
      var isActive = this.classList.contains("active2");

      // Close all accordions
      var allAccordions = document.getElementsByClassName("accordion2");
      for (j = 0; j < allAccordions.length; j++) {
        // Remove active class from section header
        allAccordions[j].classList.remove("active2");

        // Remove the max-height class from the panel to close it
        var panel = allAccordions[j].nextElementSibling;
        var maxHeightValue = getStyle(panel, "maxHeight");

        if (maxHeightValue !== "0px") {
          panel.style.maxHeight = null;
        }
      }

      // Toggle the clicked section using ternary
      isActive ? this.classList.remove("active2") : this.classList.add("active2");

      // Toggle the panel element
      var panel = this.nextElementSibling;
      var maxHeightValue = getStyle(panel, "maxHeight");

      if (maxHeightValue !== "0px") {
        panel.style.maxHeight = null;
      } else {
        panel.style.maxHeight = panel.scrollHeight + "px";
      }
    };
  }

  // Get the computed height of a certain element
  function getStyle(el, styleProp) {
    var value, defaultView = (el.ownerDocument || document).defaultView;

    if (defaultView && defaultView.getComputedStyle) {
      styleProp = styleProp.replace(/([A-Z])/g, "-$1").toLowerCase();
      return defaultView.getComputedStyle(el, null).getPropertyValue(styleProp);
    } else if (el.currentStyle) { // IE
      // sanitize property name to camelCase
      styleProp = styleProp.replace(/\-(\w)/g, function (str, letter) {
        return letter.toUpperCase();
      });
      value = el.currentStyle[styleProp];
      // convert other units to pixels on IE
      if (/^\d+(em|pt|%|ex)?$/i.test(value)) {
        return (function (value) {
          var oldLeft = el.style.left, oldRsLeft = el.runtimeStyle.left;
          el.runtimeStyle.left = el.currentStyle.left;
          el.style.left = value || 0;
          value = el.style.pixelLeft + "px";
          el.style.left = oldLeft;
          el.runtimeStyle.left = oldRsLeft;
          return value;
        })(value);
      }
      return value;
    }
  }


  if ("IntersectionObserver" in window) {
    var animationElements = document.querySelectorAll('.revealOnScroll');

    function animate(element) {
      element.classList.add("animated");
      element.style.opacity = 1;
    }

    observer = new IntersectionObserver(entries => {
      console.log(entries);
      entries.forEach(entry => {
        if (entry.intersectionRatio > 0) {
          // Animate in
          animate(entry.target);

          // Stop observing
          observer.unobserve(entry.target);
        }
      })
    });

    animationElements.forEach(currElm => {
      currElm.style.opacity = 0;
      observer.observe(currElm);
    });
  }

  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *                                                   *
  *        Invoke functions and perform setup         *
  *                                                   *
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
  // JS vs No-JS css class
  document.querySelector("body").classList.remove("no-js");

  // Scroll helper
  window.onscroll = function scrollHelper() {
    var pageHeight = (document.height || document.body.offsetHeight) - window.innerHeight;
    var scrollTop = window.scrollY || document.documentElement.scrollTop;

    // Call scroll progress on scroll
    scrollProgress(pageHeight, scrollTop);
  }

  // Year updater
  document.querySelectorAll(".copyright-year").forEach(curr => {
    curr.innerHTML = new Date().getFullYear();
  })


})()