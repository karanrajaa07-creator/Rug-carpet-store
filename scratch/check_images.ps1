$files = @(
    'assets/images/products/hero-architectural-masterpiece.jpg',
    'assets/images/products/artisan-loom-weaving.jpg',
    'assets/images/about-master-weaver.jpg',
    'assets/images/services/service-details-bespoke-hero.jpg',
    'assets/images/gallery/gallery-interior-3.jpg',
    'assets/images/home-2-como-villa.jpg',
    'assets/images/home-2-penthouse-rug.jpg',
    'assets/images/services/service-showroom-vip.jpg',
    'assets/images/gallery/gallery-interior-4.jpg',
    'assets/images/blog/blog-vintage-layered-harmony.jpg',
    'assets/images/services/service-custom-sizing.jpg',
    'assets/images/services/service-rug-cleaning.jpg',
    'assets/images/gallery/gallery-interior-2.jpg',
    'assets/images/services/service-custom-design.jpg'
)

foreach ($f in $files) {
    $exists = Test-Path $f
    Write-Output "$f : $exists"
}
