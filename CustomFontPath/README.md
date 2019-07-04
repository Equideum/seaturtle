# Custom Font Path Example

This is a small example that shows how and when using custom font paths is useful.

The document in `Assets/Example-Fonts.pdf` uses two fonts that the PDF does not embed. 

If you look at it in `Preview.app` it looks a little off. If you look at it using the example app, we added the 
`Assets/` directory as a custom font path and PSPDFKit picks up the fonts stored inside and uses them to render 
the document.
