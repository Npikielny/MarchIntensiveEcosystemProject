//
//  testView.swift
//  EcosystemBackEnd
//
//  Created by Christopher Lee on 3/12/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa
import SceneKit
import SwiftUI
import Combine

struct UserControlsView: View {
	
	@ObservedObject var userControls: UserControls
	
	@State var animalIndex: Int? = 0
	@State var animalIsSelected: Bool = false
	
	var body: some View {
		
		return GeometryReader { geometry in
			ZStack {
				VStack {
					ZStack {
						
						if self.animalIsSelected == true {
							
							selectedAnimalView(userControls: self.userControls, animalIsSelected: self.$animalIsSelected, animalIndex: self.$animalIndex)
								.transition(.move(edge: .bottom))
								.background(Color("Background"))
								.mask(RoundedRectangle(cornerRadius: 25))
								.zIndex(1)
								.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
								.shadow(radius: 5)
							
						}
						
						ZStack {
							VStack {
								HStack {
									Text("All Species")
										.font(.title)
										.bold()
										.lineLimit(2)
										.multilineTextAlignment(.leading)
									
									Spacer()
								}
								.padding()
								
								Divider()
								
								HStack {
									
									Spacer()
									
									Text("Animals: \(String(self.userControls.animalCount))")
										.font(.headline)
									
									Spacer()
									
									Text("Food: \(self.userControls.foodCount)")
										.font(.headline)
									
									Spacer()
									
								}
								.padding(.horizontal)
								
								List(self.userControls.animalList, id: \.self.node) { animal in
									
									HStack {
										
										Text("\(animal.node.name ?? "N/A") - \(animal.speciesData.name.capitalized)")
											.font(.subheadline)
										
										Spacer()
										
										Button(action: {
											withAnimation(.easeIn) {
												self.animalIndex = self.userControls.animalList.firstIndex(where: {$0.node.name == animal.node.name}) ?? 0
												self.userControls.Manager.gameController?.handler.selectionIndex = self.animalIndex
												self.animalIsSelected.toggle()
											}
										}) {
											Image("camera")
												.resizable()
												.aspectRatio(contentMode: .fit)
										}
										
									}
									.padding(.horizontal)
								}
								
								Spacer()
								
							}
						}
						.blur(radius: self.animalIsSelected ? 5 : 0)
						
					}
					
					Spacer()
					
					HStack {
						
						Button(action: {
							self.userControls.debug()
						}) {
							Text("Debug")
						}
						
						Spacer()
						
						Button(action: {
							self.userControls.createGraph()
						}) {
							Text("Graph Data")
						}
						
						Button(action: {
							self.userControls.createCSV()
						}) {
							Text("Collect Data")
						}
					}
					.padding(.horizontal)
					.padding(.bottom)
					
				}
				
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
	
}

struct selectedAnimalView: View {
	
	@ObservedObject var userControls: UserControls
	//	@Binding var animal: Animal
	@Binding var animalIsSelected: Bool
	@Binding var animalIndex: Int?
	
	var body: some View {
		
		let animal = self.userControls.Manager.gameController?.handler.selectedAnimal
		
		let sex: String = {
			if self.userControls.Manager.gameController?.handler.selectedAnimal?.sex == .Male {
				return " ♂"
			}else {
				return " ♀"
			}
		}()
		
		let breedingUrge: Float = (animal?.maxbreedingUrge ?? 0) - (animal?.breedingUrge ?? 0)
		
		return GeometryReader { geometryMain in
			
			ZStack {
				VStack {
					HStack {
						Text("\(animal?.node.name?.capitalized ?? "N/A") \(sex)")
							.font(.title)
							.bold()
						
						Spacer()
						
						Button(action: {
							withAnimation(.easeOut) {
								self.animalIndex! -= 1
								if self.animalIndex ?? 0 < 0 {
									self.animalIndex = self.userControls.animalList.count - 1
								}
								self.userControls.Manager.gameController?.handler.selectionIndex = self.animalIndex
							}
						}) {
							Image("chevron-left")
								.resizable()
								.aspectRatio(contentMode: .fit)
							
						}
						.background(Color.clear)
						
						Button(action: {
							withAnimation(.easeOut) {
								self.animalIndex! += 1
								if self.animalIndex ?? 0 >= self.userControls.animalList.count {
									self.animalIndex = 0
								}
								self.userControls.Manager.gameController?.handler.selectionIndex = self.animalIndex
								
							}
						}) {
							Image("chevron-right")
								.resizable()
								.aspectRatio(contentMode: .fit)
							
						}
						.background(Color.clear)
						
						Button(action: {
							withAnimation(.easeOut) {
								self.animalIndex = nil
								self.userControls.Manager.gameController?.handler.selectionIndex = self.animalIndex
								self.animalIsSelected.toggle()
							}
						}) {
							Text("X")
								.foregroundColor(Color.red)
							
						}
						.background(Color.clear)
					}
					.padding()
					
					Divider()
					
					HStack {
						VStack(alignment: .leading, spacing: 10.0) {
							
							Text(String("Species: \(animal?.speciesData.name.capitalized ?? "N/A")"))
								.font(.headline)
							
							Text("Food Type: \(self.userControls.foodType)")
								.font(.headline)
							
							Text(String("Age: \(String(format: "%.2f", animal?.age ?? 0))"))
								.font(.headline)
							
							
							Text(String("Speed: \(String(format: "%.2f", animal?.Speed ?? 0))"))
								.font(.headline)
							
							
							Text(String("Efficiency: \(String(format: "%.2f", animal?.efficiency ?? 0))"))
								.font(.headline)
							
							
							Text("Priority: \(self.userControls.priority)")
								.font(.headline)
							
							
						}
						
						Divider()
						
						SceneKitView(modelName: (animal?.speciesData.name ?? "N/A"), scene: SCNScene(named: "art.scnassets/\(animal?.speciesData.name ?? "N/A").scn")!)
						
					}
					.frame(height: geometryMain.size.height * 0.3)
					.padding(.horizontal)
					
					Divider()
					
					Spacer()
					
					VStack(alignment: .leading, spacing: 20.0) {
						
						
						HStack {
							
							Text("Health: \(String(format: "%.0f", animal?.health ?? 0))")
								.font(.headline)
							
							Spacer()
							
							GeometryReader { geometry in
								ZStack(alignment: .leading) {
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.gray)
										.frame(width: geometry.size.width)
									
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.green)
										.frame(width: geometry.size.width * (CGFloat((animal?.health ?? 0) / (animal?.maxhealth ?? 0))))
									
								}
							}
							.frame(height: 15)
							
						}
						
						HStack {
							
							Text("Thirst: \(String(format: "%.0f", animal?.thirst ?? 0))")
								.font(.headline)
							
							Spacer()
							
							GeometryReader { geometry in
								ZStack(alignment: .leading) {
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.gray)
										.frame(width: geometry.size.width)
									
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.blue)
										.frame(width: geometry.size.width * (CGFloat((animal?.thirst ?? 0) / (animal?.maxthirst ?? 0))))
									
								}
							}
							.frame(height: 15)
							
						}
						
						HStack {
							
							Text("Hunger: \(String(format: "%.0f", animal?.hunger ?? 0))")
								.font(.headline)
							
							Spacer()
							
							GeometryReader { geometry in
								ZStack(alignment: .leading) {
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.gray)
										.frame(width: geometry.size.width)
									
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.orange)
										.frame(width: geometry.size.width * (CGFloat((animal?.hunger ?? 0) / (animal?.maxhunger ?? 0))))
									
								}
							}
							.frame(height: 15)
							
						}
						
						HStack {
							
							Text("Breeding Urge: \(String(format: "%.0f", breedingUrge))")
								.font(.headline)
							
							Spacer()
							
							GeometryReader { geometry in
								ZStack(alignment: .leading) {
									
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.gray)
										.frame(width: geometry.size.width)
									
									RoundedRectangle(cornerRadius: 25)
										.foregroundColor(Color.pink)
										.frame(width: geometry.size.width * (CGFloat(breedingUrge / (animal?.maxbreedingUrge ?? 0))))
									
								}
							}
							.frame(height: 15)
							
						}
						
						Spacer()
					}
					.padding(.horizontal)
					
				}
			}
			
		}
		
		
		
	}
	
}


//struct TestView_Previews: PreviewProvider {
//
//
//	static var previews: some View {
//
//		TestView(userControls: UserControls())
//	}
//}

struct SceneKitView: NSViewRepresentable {
	
	typealias NSViewType = SCNView
	
	@State var modelName: String
	
	@State var scene: SCNScene
	
	func makeNSView(context: Context) -> SCNView {
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		self.scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
		
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = .omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		self.scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = .ambient
		ambientLightNode.light!.color = NSColor.darkGray
		self.scene.rootNode.addChildNode(ambientLightNode)
		
		// retrieve the ship node
		let model = self.scene.rootNode.childNode(withName: self.modelName, recursively: true)
		
		model?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
		
		// animate the 3d object
		
		// retrieve the SCNView
		let scnView = SCNView()
		return scnView
	}
	
	
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		
		nsView.scene = self.scene
		
		//		nsView.scene?.rootNode.childNodes.first?.runAction(SCNAction.rotateBy(x: 0, y: 0.25, z: 0, duration: 0.1))
		
		// allows the user to manipulate the camera
		nsView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		nsView.showsStatistics = false
		
		// configure the view
		nsView.backgroundColor = NSColor.white
	}
	
}

extension AnyTransition {
	static var moveAndFade: AnyTransition {
		let insertion = AnyTransition.move(edge: .bottom)
			.combined(with: .opacity)
		let removal = AnyTransition.move(edge: .bottom)
			.combined(with: .opacity)
		return .asymmetric(insertion: insertion, removal: removal)
	}
}
