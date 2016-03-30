<?php
/**
 * Copyright © 2016, Ambroise Maupate and Julien Blanchet
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the ROADIZ shall not
 * be used in advertising or otherwise to promote the sale, use or other dealings
 * in this Software without prior written authorization from Ambroise Maupate and Julien Blanchet.
 *
 * @file clear_cache.php
 * @author Ambroise Maupate
 */
use RZ\Roadiz\Core\Kernel;
use RZ\Roadiz\Core\HttpFoundation\Request;
use RZ\Roadiz\Utils\Clearer\AssetsClearer;
use RZ\Roadiz\Utils\Clearer\ConfigurationCacheClearer;
use RZ\Roadiz\Utils\Clearer\DoctrineCacheClearer;
use RZ\Roadiz\Utils\Clearer\NodesSourcesUrlsCacheClearer;
use RZ\Roadiz\Utils\Clearer\OPCacheClearer;
use RZ\Roadiz\Utils\Clearer\RoutingCacheClearer;
use RZ\Roadiz\Utils\Clearer\TemplatesCacheClearer;
use RZ\Roadiz\Utils\Clearer\TranslationsCacheClearer;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\IpUtils;

if (version_compare(phpversion(), '5.4.3', '<')) {
    echo 'Your PHP version is ' . phpversion() . "." . PHP_EOL;
    echo 'You need a least PHP version 5.4.3';
    exit(1);
}

define('ROADIZ_ROOT', dirname(__FILE__));
// Include Composer Autoload (relative to project root).
require("vendor/autoload.php");

$allowedIp = [
    //'10.0.2.2', // vagrant host
    '127.0.0.1', 'fe80::1', '::1' // localhost
];

// This check prevents access to debug front controllers that are deployed by accident to production servers.
// Feel free to remove this, extend it, or make something more sophisticated.
if (isset($_SERVER['HTTP_CLIENT_IP'])
    || isset($_SERVER['HTTP_X_FORWARDED_FOR'])
    || (!IpUtils::checkIp(@$_SERVER['REMOTE_ADDR'], '192.168.1.0/24')
        && !(in_array(@$_SERVER['REMOTE_ADDR'], $allowedIp))
    || php_sapi_name() === 'cli-server')
) {
    $response = new JsonResponse([
        'status' => 'fail',
        'error' => 'You are not allowed to access this file.',
    ], JsonResponse::HTTP_UNAUTHORIZED);
    $response->send();
    exit();
}

$kernel = Kernel::getInstance('prod', false);
$kernel->boot();
$request = Request::createFromGlobals();
$kernel->container['request'] = $request;

$clearers = [
    // PROD
    new AssetsClearer($kernel->getCacheDir()),
    new RoutingCacheClearer($kernel->getCacheDir()),
    new TemplatesCacheClearer($kernel->getCacheDir()),
    new TranslationsCacheClearer($kernel->getCacheDir()),
    new ConfigurationCacheClearer($kernel->getCacheDir()),
    new NodesSourcesUrlsCacheClearer($kernel->getService('nodesSourcesUrlCacheProvider')),
    new OPCacheClearer(),
    // Keep doctrine at the end
    new DoctrineCacheClearer($kernel->getService('em')),
];

$text = [
    'status' => 'ok',
    'trace' => [],
    'errors' => [],
];

foreach ($clearers as $clearer) {
    try {
        $clearer->clear();
        $text['trace'][] = $clearer->getOutput();
    } catch (\Exception $e) {
        $text['errors'][] = $e->getMessage();
    }
}

$response = new JsonResponse($text);
$response->send();
