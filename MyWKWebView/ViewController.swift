//
//  ViewController.swift
//  MyWKWebView
//
//  Created by Gilmer Marcano on 8/19/19.
//  Copyright © 2019 Gilmer Marcano. All rights reserved.

/*MUY IMPORTANTE: En el info.plist del proyecto > Botón derecho > Open as > Source code tenemos que añadir antes del </dict> final lo siguiente:
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>

Hacemos esto para que nuestro WebView pueda cargar url http, no solo las https como hace por defecto. Gracias!
 */

import UIKit
import WebKit

final class ViewController: UIViewController {
   
    // MARK: - Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    // MARK: - Private
    private let searchBar = UISearchBar()
    private var webView: WKWebView! //estamos haciendo el webView por codigo
    private let refreshControl = UIRefreshControl() //estamos instanciando a partir de UIRefreshControl para darle mas abajo la funcionalidad de que la pagina refresque cuando le damos scroll hacia abajo
    private let baseUrl = "http://www.google.com"
    private let searchPath = "/search?q=" // es para que buscar una url en google
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //Navigations buttons
        
        //haremos que los botones esten desactivados cuando arranque la app
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
    // Search bar
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self //Es para activar el delegado
    
    // Web View
        
        let webViewPrefs = WKPreferences()
        //por ejemplo si quiero que soporte javascript
        webViewPrefs.javaScriptEnabled = true
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true //-> para que se abran diferentes ventanas en nuestro explorador
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        
        webView = WKWebView(frame: view.frame, configuration: webViewConf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight] //le estamos diciendo que ocupe toda la pantalla
        //vamos a añadirlo a nuetra vista
        webView.scrollView.keyboardDismissMode = .onDrag //es para cuando hago scroll me oculte el teclado
        
        view.addSubview(webView)
        
        webView.navigationDelegate = self
        
    // Refresh Control
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl) //este es el refresh control
        view.bringSubviewToFront(refreshControl) //es para mandar el refreshcontrol para que se nos vea en el primer plano en la jerarquia de vistas
        
        load(url: baseUrl)
        
}

    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack() //esto para que el boton funcione hacia atras
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        webView.goForward() //esto para que el boton funcione hacia adelante
    }
    
    // MARK: - Private Methods
    
    private func load(url:String){
        
        var urlToLoad: URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url){
            
        urlToLoad = url
    }else{
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(url)")!
    }
        webView.load(URLRequest(url:urlToLoad))
}
    @objc private func reload(){
        webView.reload() //reload() lo que hace es recargar la vista y no dejarla cargado infinitamente
    }
    
    
}

    // MARK: - UISearchBarDelegate

    extension ViewController: UISearchBarDelegate{
    //escribo searchBarSearchButtonClicked a continuacion para cuando apretemos el boton buscar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)    //le dice a la barra que terminamos de  editar y se oculta
        load(url: searchBar.text ?? "")  //para usar Buscar en la barra de navegacion
 
    }
}
    // MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing() // es para que deje de cargarse
        
        backButton.isEnabled = webView.canGoBack //es para usar el boton
        forwardButton.isEnabled = webView.canGoForward
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        refreshControl.beginRefreshing()
        searchBar.text = webView.url?.absoluteString //esto es para mostrar la url en la barra de naavegacion
    
    }
    
}
