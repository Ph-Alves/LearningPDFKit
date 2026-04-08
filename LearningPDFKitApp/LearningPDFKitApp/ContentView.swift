//
//  ContentView.swift
//  LearningPDFKitApp
//
//  Created by Paulo Henrique Costa Alves on 07/04/26.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// O PDFKit funciona com 2 pontos
// Precisamos de uma PDFView, e de um PDFDocument
// O PDFDocument permite a leitura de documentos usando um url que podemos fazer via bundle
// O pdfview possui .document, que permite mostrar o documento.
struct ContentView: View {
    var body: some View {
        let imagens: [UIImage] = [
            UIImage(imageLiteralResourceName: "Untitled_Artwork"),
            UIImage(imageLiteralResourceName: "Untitled_Artwork"),
            UIImage(imageLiteralResourceName: "Untitled_Artwork")
        ]
        let data = criarPDF(imagens: imagens)
        VStack {
            if let data = data {
                let docTransferivel = DocumentoPDF(data: data)
                pdfView(data: data)
                // ShareLink serve para compartilhar a data gerada
                ShareLink(item: docTransferivel, preview: SharePreview("MeuArquivoFinal.pdf", image: Image("Untitled_Artwork"))) {
                    Label("Exportar para o celular", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            } else {
                EmptyView()
            }
        }
        .padding()
    }
}

// Isso é so uma estrutura que recebe a data e retorna como um nome específico para que não salve como dados puro.
// O transferable define que essa struct vai para fora do app, assim o shareLink sabe que essa estrutura pode ser movida
struct DocumentoPDF: Transferable {
    let data: Data
    
    // isso aqui que define a regra de tradução, o sistema consulta essa variável para saber como extrair os dados
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { documento in
            documento.data
        }
        // Etiqueta
        .suggestedFileName("MeuArquivoFinal.pdf")
    }
}

// Conversor de UIView (Pois o PDFView é UIView)
struct pdfView: UIViewRepresentable {
    var data: Data
    
    func makeUIView(context: Context) -> some UIView {
        let view = PDFView()
        view.document = PDFDocument(data: data)
        view.autoScales = true
        view.pageShadowsEnabled = true
        view.displaysAsBook = true
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

// Função para escrever no pdf e gerar um novo
func criarPDF(imagens: [UIImage]) -> Data? {
    // Tamanhos da página
    let pageWidth: CGFloat = 595.2
    let pageHeight: CGFloat = 841.8
    // Tem que ser um rect
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    
    // O renderizador, que vai gerar o pdf
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: UIGraphicsPDFRendererFormat())
    
    // Preparamos a página aqui, o context é o seu objeto do tipo format la em cima
    let pdfData = renderer.pdfData { (context) in
        // Começa a pagina
        context.beginPage()
        
        // Valor inicial da imagem e margem
        // Posição Y e X
        var currentY: CGFloat = pageHeight / 4
        let currentX: CGFloat = pageWidth / 2.5
        // Margem
        let margin: CGFloat = 20
        // Width e Height disponivel
        let availableWidth = pageWidth - (margin * 2)
        let availableHeight = pageHeight - (margin * 2)
        
        // Por imagem, ele monta um rect e usa o .draw
        for imagem in imagens {
            // Proporção
            // ratio = Valor disponível da tela / valor da imagem
            // Assim não quebra a imagem
            let widthRatio = (availableWidth / imagem.size.width) / 2
            let heightRatio = (availableHeight / imagem.size.height) / 2
            
            // Tamanho da imagem
            let imageWidth = availableWidth * widthRatio
            let imageHeight = imagem.size.height * heightRatio / 3
            
            // Prepara o retângulo do tamanho da imagem.
            let drawRect = CGRect(x: currentX, y: currentY, width: imageWidth, height: imageHeight)
            
            // Isso que faz ele saber que é pra usar a imagem, o rect so limita o tamanho dela.
            imagem.draw(in: drawRect)
            
            currentY += imageHeight + 10
        }
    }
    return pdfData
}

#Preview {
    ContentView()
}
