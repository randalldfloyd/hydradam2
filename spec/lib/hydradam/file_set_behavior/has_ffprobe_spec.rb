require 'rails_helper'
require 'hydradam/file_set_behavior/has_ffprobe'

describe HydraDAM::FileSetBehavior::HasFfprobe, :requires_fedora do

  subject do
    # An anonymous class that inherits from ActiveFedora::Base
    # and includes the HydraDAM::FileSetBehavior::HasFfprobe module.
    Class.new(ActiveFedora::Base) do
      include HydraDAM::FileSetBehavior::HasFfprobe
    end.new
  end

  after(:all) do
    subject.delete rescue nil
  end

  it 'exposes accessors #ffprobe and #ffprobe=' do
    expect(subject).to respond_to :ffprobe
    expect(subject).to respond_to :"ffprobe="
  end

  describe '#ffprobe=' do
    it 'requires an XMLFile' do
      expect{ subject.ffprobe = "this will fail" }.to raise_error
    end

    it 'accepts a XMLFile' do
      subject.save! # the parent object must be saved before attaching files.
      expect{ subject.ffprobe = XMLFile.new }.to_not raise_error
    end
  end

  describe '#assign_properties_from_ffprobe' do
    let(:ffprobe_file) { File.open('./spec/fixtures/ffprobe/ffprobe_1.xml') }

    before do
      Hydra::Works::AddFileToFileSet.call(subject, ffprobe_file, :ffprobe)
      subject.assign_properties_from_ffprobe
    end

    it 'assigns values from ffprobe XML file to RDF properties on the object' do
      expect(subject.filename).to eq "/cookies/pizza.wav"
    end
  end

  context 'when the including class does not inherit from ActiveFedora::Base' do
    let(:class_with_missing_dependency) do
      # An anonymous class that includes the HydraDAM::FileSetBehavior::HasFfprobe
      # module but does not inherity from ActiveFedora::Base like it should
      Class.new do
        include HydraDAM::FileSetBehavior::HasFfprobe
      end
    end

    it 'raises an error' do
      expect{ class_with_missing_dependency }.to raise_error DependsOn::MissingDependencies
    end
  end
end
