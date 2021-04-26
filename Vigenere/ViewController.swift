//
//  ViewController.swift
//  Vigenere
//
//  Created by Vitor Demenighi on 15/04/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    let main: Main = Main()
    var mainText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchedButton(_ sender: Any) {
        let path = "/Users/vitordemenighi/Desktop/TrabVigenere/Sources/texto1.txt"
        var mainText: String = ""
        
        do {
            let url = URL(fileURLWithPath: path)
            mainText = try String(contentsOf: url, encoding: String.Encoding.utf8)
            
        } catch {
            print("Erro ao ler o arquivo")
        }
        
        
//        mainText = textView.text
        let keySize = main.discoverKeySize(originalText: mainText)
        let keyValue = main.discoveryKeyValue(keySize: keySize, text: mainText)
        let result = main.decipher(key: keyValue, originalText: mainText)
        print(result)
    }
}

class Main {
    
    func discoverKeySize(originalText: String) -> Int {
        var lettersFrequency: [String: Int] = [:]
        
        /// Verifica o indice de coincidencia de chaves de tamanhos de 0 á 100
        for keySize in 1...100 {
            
            /// Separa o texto de acordo com o tamanho da chave
            let splitedText = splitText(keySize: keySize, orignalText: originalText)
        
            var coincidenceIndexTotal: Double = 0.0
            
            /// Pega o indice de coincidencia de cada parte separada do texto
            for text in splitedText {
                lettersFrequency = getFrequency(text: text)
                let coincidenceIndex = getCoincidenceIndex(frequency: lettersFrequency)
                coincidenceIndexTotal += coincidenceIndex
            }
            
            /// Pega a média do indice de coincidencia
            let coincidenceIndexAverage = coincidenceIndexTotal/Double(keySize)
            
            /// Verifica se o resultado está de acordo com o valor aceitável para lingua portuguesa
            if verifyResult(coincidenceIndexAverage) {
                return keySize
            }
        }
        
        return 0
    }
    
    func discoveryKeyValue(keySize: Int, text: String) -> String {
        var lettersFrequency: [String: Int] = [:]
        var keyCandidate_A = ""
        var keyCandidate_E = ""
        
        /// Letras mais frequentes na lingua portuguesa
        let A_value = alphabetValues["a"]!
        let E_value = alphabetValues["e"]!
        
        /// Separa o texto em colunas de acordo com o tamanho da chave
        let splitedText = splitText(keySize: keySize, orignalText: text)
        
        for text in splitedText {
            lettersFrequency = getFrequency(text: text)
            let mostFrenquentlyLetter = getLetter(lettersFrequency: lettersFrequency)
            
            /// Pega os dois cadidados principais a senha
            keyCandidate_A += getKeyCandidate(with: A_value, mostFrenquentlyLetter.0)
            keyCandidate_E += getKeyCandidate(with: E_value, mostFrenquentlyLetter.0)
        }

        /// Encontra as possiveis combinações de letras das duas chaves candidatas
        let keysCombinations = getCombinations(candidateOne: keyCandidate_A, candidateTwo: keyCandidate_E)
        
        /// Entre as chaves cadidatas encontra a chave correta
        let correctKey = foundCorrectKey(combinations: keysCombinations, originalText: text)
        
        return correctKey
    }
    
    // MARK: - Common Functions
    
    /// Retornar as combinações possiveis entre as duas chaves. Alterna entre os caracteres das posições (exemplo: troca a 1 letra da chave 1 pela 1 letra da chave 2 e assim por diante)
    func getCombinations(candidateOne: String, candidateTwo: String) -> [String] {
        var result: [String] = []
        let keySize = max(candidateOne.count, candidateTwo.count)
        let size = Int(pow(Double(2), Double(keySize)))
        
        for i in 0..<size {
            var binary = String(i, radix: 2)
            
            while binary.count < keySize {
                let value = "0" + binary
                binary = value
            }
            
            var newKey = ""
            for j in 0..<binary.count {
                if binary[j] == "0" {
                    newKey += candidateOne[j]
                } else {
                    newKey += candidateTwo[j]
                }
            }
            
            result.append(newKey)
        }
        
        return result
    }
    
    /// Encontra  a chave correta decifrando o text e testando a frequencia das letras menos comuns
    func foundCorrectKey(combinations: [String], originalText: String) -> String {
        var previousScore = Int.max
        var choosenKey = ""
        let shortedText = reduceTextLength(originalText: originalText, textCharactersLimitNumber: 1000)
        
        for candidate in combinations {
            let resultText = decipher(key: candidate, originalText: shortedText)
            let score = getLessFrequencyPortugueseLetters(text: resultText)
        
            if  score < previousScore  {
                choosenKey = candidate
                previousScore = score
            }
        }
        
        return choosenKey
    }
    
    /// Reduz o comprimento do texto para melhorar a performace do algoritmo
    func reduceTextLength(originalText: String, textCharactersLimitNumber: Int) -> String {
        
        if originalText.count > textCharactersLimitNumber {
            let end = originalText.index(originalText.startIndex, offsetBy: textCharactersLimitNumber)
            return String(originalText[..<end])
        }
        return originalText
    }
    
    
    /// Decifra o texto de acordo com a chave passada por parametro
    func decipher(key: String, originalText: String) -> String {
        var keyPosition = -1
        var resultText = ""
        
        for i in 0..<originalText.count {
            keyPosition += 1
            
            if keyPosition > (key.count - 1) {
                keyPosition = 0;
            }
            
            let letter = originalText[i]
            let keyLetter = key[keyPosition]
            let lcif = alphabetValues[letter]!
            let lcha = alphabetValues[keyLetter]!
            var lmensagem = lcif - lcha
            
            if lmensagem < 0 {
                lmensagem = 26 + lmensagem
            }
            
            let messageLetter = getLetter(with: lmensagem)
            resultText += messageLetter
        }
        
        return resultText
    }
    
    /// Testa a frequência das letras menos comuns da lingua portuguesa no texto passado por parametro
    func getLessFrequencyPortugueseLetters(text: String) -> Int {
        var kScore = 0
        var wScore = 0
        var yScore = 0
        
        for letter in text {
            kScore += letter == "k" ? 1 : 0
            wScore += letter == "w" ? 1 : 0
            yScore += letter == "y" ? 1 : 0
        }
        
        return kScore + wScore + yScore
    }
    
    /// Encontra a chave candidata de acordo com o valor da letra refência escolhida (A ou E) e a a letra mais frequente da coluna
    func getKeyCandidate(with letterValue: Int, _ mostFrenquentlyLetter: String) -> String {
        let mostFrenquentlyLetterValue = alphabetValues[mostFrenquentlyLetter]!
        let resultValueLetter = mostFrenquentlyLetterValue - letterValue
        return getLetter(with: resultValueLetter)
    }
    
    /// Retorna a letra de maior frequência nowwtexto
    func getLetter(lettersFrequency: [String: Int]) -> (String, Int) {
        var result = ("", 0)
        for letter in lettersFrequency {
            if letter.value > result.1 {
                result.0 = letter.key
                result.1 = letter.value
            }
        }
        
        return result
    }
    
    /// Retorna a quantidade de vezes que a letra aparece no texto
    func getFrequency(text: String) -> [String: Int] {
        var resultDic: [String: Int] = [:]
    
        for character in text {
            if character != " " {
                let previousValue =  resultDic[String(character)] ?? 0
                resultDic[String(character)] = previousValue + 1
            }
        }
        
        return resultDic
    }
    
    func splitText(keySize: Int, orignalText: String) -> [String]  {
        var resultString: [String] = [String](repeating: "", count: keySize)
        let noSpacesText = orignalText.replacingOccurrences(of: " ", with: "")
        var count = 0
        
        for index in 0..<noSpacesText.count {
            resultString[count] += String(noSpacesText[index])
            
            if count == keySize - 1 {
                count = 0
            } else {
                count += 1
            }
        }
        
        return resultString
    }
    
    // MARK: - IC Functions
    
    func getCoincidenceIndex(frequency: [String: Int]) -> Double {
        var numbersFrequencySummation: Double = 0.0
        var amountOfLetters: Double = 0.0

        for letter in frequency {
            numbersFrequencySummation += Double(letter.value * (letter.value - 1))
            amountOfLetters += Double(letter.value)
        }

        if amountOfLetters == 0.0 {
            return 0.0
        } else {
            return numbersFrequencySummation / ( amountOfLetters * (amountOfLetters - 1))
        }
    }
    
    func verifyResult(_ coincidenceIndex: Double) -> Bool {
        let coincidenceIndexPortuguese = 0.072723
        
        return (coincidenceIndex > (coincidenceIndexPortuguese - 0.01) && coincidenceIndex < (coincidenceIndexPortuguese + 0.01))
    }
    
    // MARK: - Alphabet
    
    var alphabetValues = ["a":0,
                          "b":1,
                          "c":2,
                          "d":3,
                          "e":4,
                          "f":5,
                          "g":6,
                          "h":7,
                          "i":8,
                          "j":9,
                          "k":10,
                          "l":11,
                          "m":12,
                          "n":13,
                          "o":14,
                          "p":15,
                          "q":16,
                          "r":17,
                          "s":18,
                          "t":19,
                          "u":20,
                          "v":21,
                          "w":22,
                          "x":23,
                          "y":24,
                          "z":25]
    
    /// Retorna a letra do alfabeto de acordo com o número passado por parâmetro
    func getLetter(with number: Int) -> String {
        for letter in alphabetValues where letter.value == number {
            return letter.key
        }
        return ""
    }
}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
