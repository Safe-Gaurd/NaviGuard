'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "8fdefe85b99e664e367c9c54f6232911",
"assets/AssetManifest.bin.json": "57d77d51464c77106c814d4908f6ca30",
"assets/AssetManifest.json": "546d38b20c8dd81d59865f92b8d9c696",
"assets/assets/auth/forgot_password.jpg": "db4f15e72558516794f2d02e73e8d610",
"assets/assets/auth/google.jpg": "5096e746d19b9c407089dfd220471bbe",
"assets/assets/auth/login.jpg": "5eb0a5e93b43b0580a040e9f36e12afe",
"assets/assets/auth/signup.jpg": "91290126787c750bccc9ffe74fd29796",
"assets/assets/call/ambulance.jpg": "7a5de42b073777c950a9482a8619c1b7",
"assets/assets/call/fav.jpg": "3c089712bef37d38ad5e2ea466fa7369",
"assets/assets/call/fav_screen.jpg": "3e20072e2c91befff3641f64b1e29d90",
"assets/assets/call/firefighter.jpg": "9f982aee0aad0d3266a5118a4ab8ce76",
"assets/assets/call/india_flag.jpg": "c6461e4306d49a1d13d6d9398296f29d",
"assets/assets/call/police.jpg": "cbfe0ec1c4b058572a3ac508371e4eee",
"assets/assets/feed/cmr.jpg": "f3c588e750d316eb8a53d86f2b0ed12e",
"assets/assets/feed/dmart.jpg": "ed5a54f6474bf34008d262a79ff94d18",
"assets/assets/feed/klm.jpg": "6ff5359b245ea73770baa45385a1881b",
"assets/assets/feed/reliance.jpg": "6fca216aed6b2bb87ca33e7659abd6e7",
"assets/assets/home/accident_analysis.jpg": "bfd276c1a94021e93f8072003e25db73",
"assets/assets/home/cloudy.jpg": "3c2773ce0221bfb4efe38e6e822cb605",
"assets/assets/home/dashcam.jpg": "0619efb880dc5c82de169e80061c5869",
"assets/assets/home/driving.json": "cfb4a092b6630df9042b84adb151e3e4",
"assets/assets/home/emergency.jpg": "6d4aca248e05c97a37a4b37040c15a9d",
"assets/assets/home/insurance.jpg": "2a1f627a6dfec245a79443b2d1d4221d",
"assets/assets/home/maps.jpg": "81ad614d4147f3d654853d92b19466e4",
"assets/assets/home/notification.jpg": "dee4116c97abcc3fb54ff0d3c68921da",
"assets/assets/home/profile.jpg": "f1042328cf852243cfdcdb13561a3038",
"assets/assets/home/rainy.jpg": "bf283a72cee2618eece356a9dc40e9b0",
"assets/assets/home/sunny.jpg": "d140c18c75205300ee5e702502788e2e",
"assets/assets/home/weather.JPG": "6da47fa2155d9db9c9f2b1f6329c9488",
"assets/assets/maps/accident.jpg": "36fee520591c93638618ed7f498e4b46",
"assets/assets/maps/something_went_wrong.png": "f61a558e998a0ce5bce95f2a9dffce0a",
"assets/assets/onboarding_screen/app_logo.jpg": "669eba3fea6716f6ac9b95f78200b3a1",
"assets/assets/onboarding_screen/app_logo.png": "6b16dae32165289720f794870a153b12",
"assets/assets/onboarding_screen/screen1.json": "0151eb8810308d42bfafd57410f1bd5e",
"assets/assets/onboarding_screen/screen2.json": "6961df9671db68bc43ed85cec4d91d9b",
"assets/assets/onboarding_screen/screen3.jpg": "752ab953ad760759b7ed14b65e413e08",
"assets/assets/onboarding_screen/screen4.png": "a6d5d232b8573d826e9870c9fa475e40",
"assets/assets/splash_screen/logo.png": "2c19b3da6b8c5adc4071960a4edecda1",
"assets/assets/splash_screen/splashscreen_lottie.json": "f87aeed7de8f325ac8de62fd24323b24",
"assets/assets/weather/cloudy.jpg": "d326ae97ecb4fa0687b76e6b457a6808",
"assets/assets/weather/rainy.jpg": "764260aa76d064723516ec83fdc15251",
"assets/assets/weather/sunny.jpg": "0019c84f0486c59b642c3d661245800b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "31fcc19fb57b244291f9dd0bd0c733ce",
"assets/NOTICES": "10653f4dfb6e0b97c1188a68a7711c6a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "0e9d9765bf8139fc11a630c3c0788bbb",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "9d47c4b1571cf4e19a6319bedd84457f",
"icons/Icon-192.png": "6a34f095570530accc45f31811460be6",
"icons/Icon-512.png": "30fe654280af488d2d52ebabdc142b86",
"icons/Icon-maskable-192.png": "6a34f095570530accc45f31811460be6",
"icons/Icon-maskable-512.png": "30fe654280af488d2d52ebabdc142b86",
"index.html": "782d5f3190970af10e6aa6fce362e544",
"/": "782d5f3190970af10e6aa6fce362e544",
"main.dart.js": "96832402f9f37fc0c36629e1f5629e4a",
"manifest.json": "45604645868b4fd73145399aa4c718b2",
"version.json": "792dd47c45ba4894b3c3568f8312c2b0"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
